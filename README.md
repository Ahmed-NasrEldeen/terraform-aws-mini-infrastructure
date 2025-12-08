# Terraform AWS Mini Infrastructure

A minimal yet production-style Terraform project that provisions AWS networking basics together with a public EC2 instance. The configuration uses reusable modules so you can easily expand it into a larger environment.

## What it provisions
- VPC with public subnet, internet gateway, and public route table
- Security group that allows SSH (22) and HTTP (80) over IPv4 and IPv6
- Amazon Linux 2 `t2.micro` instance with Apache installed and a simple landing page
- Terraform remote state configured for an S3 backend (bucket must already exist)

## Architecture

```
+----------------------------------------------------+
|                    AWS Region                      |
|                                                    |
|  +----------------------------------------------+  |
|  | VPC (10.0.0.0/16)                             |  |
|  |                                              |  |
|  |  +-------------------+      +---------------+|  |
|  |  | Public Subnet     |------| Internet GW   ||  |
|  |  | (10.0.1.0/24)     |      +---------------+|  |
|  |  |                   |                      |  |
|  |  |  EC2 t2.micro     |<----- Route Table ----|  |
|  |  |  (SSH + HTTP)     |                      |  |
|  |  +-------------------+                      |  |
|  +----------------------------------------------+  |
+----------------------------------------------------+
```

## Repo structure

```
.
|-- main.tf          # Wires modules together
|-- variables.tf     # User-configurable inputs
|-- providers.tf     # Terraform + AWS provider constraints + S3 backend
|-- outputs.tf       # Friendly outputs (IP, IDs)
|-- modules
|   |-- vpc          # VPC, subnet, IGW, routes
|   `-- ec2          # Security group + EC2 instance
`-- README.md
```

## Prerequisites
- Terraform >= 1.5
- AWS credentials set via environment variables, shared credentials file, or AWS SSO
- An S3 bucket for remote state. The config expects `mini-infra-tf-state` in `eu-west-1`; either create it or override the backend values.

## Configure state backend

The S3 backend is declared in `providers.tf`. Create the bucket (or update the block) before running `terraform init`:

```bash
aws s3api create-bucket --bucket mini-infra-tf-state --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
```

To use a different bucket/region without editing the file, supply backend overrides on init:

```bash
terraform init ^
  -backend-config="bucket=my-tf-state-bucket" ^
  -backend-config="region=us-west-2" ^
  -backend-config="key=mini-infra/terraform.tfstate"
```

## Configuration

Inputs (see `variables.tf`):

| Variable        | Description                             | Default      |
| --------------- | --------------------------------------- | ------------ |
| `region`        | AWS region for the provider and backend | `eu-west-1`  |
| `instance_type` | EC2 instance type                       | `t2.micro`   |
| `vpc_cidr`      | CIDR block for the VPC                  | `10.0.0.0/16`|
| `subnet_cidr`   | CIDR block for the public subnet        | `10.0.1.0/24`|

Common tags live in `main.tf` (`local.common_tags`), and each module merges in its own component tags. Override inputs via CLI flags or a `terraform.tfvars` file, for example:

```hcl
region        = "us-west-2"
instance_type = "t3.micro"
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
```

## Getting started

1. Install Terraform and configure your AWS credentials.
2. Ensure the S3 backend bucket exists or override it during `terraform init`.
3. Adjust the values in `variables.tf` (or supply `-var` overrides) if you need different regions, CIDRs, or instance types.

### Run the project

```bash
terraform init
terraform plan
terraform apply
```

The plan/apply commands can take `-var "region=us-west-2"` (and so on) to override defaults.

### Outputs

After `terraform apply` you will receive:

- `vpc_id` - ID of the provisioned VPC
- `instance_id` - EC2 instance identifier
- `public_ip` - Public IPv4 you can SSH/HTTP into (HTTP returns the default Amazon Linux test page)

### Accessing the instance

- HTTP: `curl http://<public_ip>` should return the Apache page overwritten with "Hello from mini infra".
- SSH: The security group allows port 22, but the EC2 instance does not specify a `key_name`; add one in `modules/ec2/main.tf` (and provide the key pair) if you need SSH access.

### Cleanup

Destroy all resources when you are finished:

```bash
terraform destroy
```

Answer `yes` and Terraform will remove the VPC, subnet, internet gateway, route table, security group, and EC2 instance.

## Customization ideas

- Add a private subnet and NAT gateway for a multi-tier topology.
- Replace the single instance with an Auto Scaling group + load balancer.
- Wire the modules into a CI/CD pipeline for consistent provisioning.
