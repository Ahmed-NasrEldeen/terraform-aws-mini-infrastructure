# Terraform AWS Mini Infrastructure

A minimal yet production-style Terraform project that provisions AWS networking basics together with a public EC2 instance. The configuration uses reusable modules so you can easily expand it into a larger environment.

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

## Repo Structure

```
.
├── main.tf          # Wires modules together
├── variables.tf     # User-configurable inputs
├── providers.tf     # Terraform + AWS provider constraints
├── outputs.tf       # Friendly outputs (IP, IDs)
├── modules
│   ├── vpc          # VPC, subnet, IGW, routes
│   └── ec2          # Security group + EC2 instance
└── README.md
```

## Getting Started

1. Install [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5 and configure your AWS credentials (via environment variables, shared credentials file, or AWS SSO).
2. Adjust the values in `variables.tf` (or supply `-var` overrides) if you need different regions, CIDRs, or instance types.

### Run the project

```bash
terraform init
terraform plan
terraform apply
```

The plan/apply commands can take `-var "region=us-west-2"` (and so on) to override defaults.

### Outputs

After `terraform apply` you will receive:

- `vpc_id` – ID of the provisioned VPC
- `instance_id` – EC2 instance identifier
- `public_ip` – Public IPv4 you can SSH/HTTP into (HTTP returns the default Amazon Linux test page)

### Cleanup

Destroy all resources when you are finished:

```bash
terraform destroy
```

Answer `yes` and Terraform will remove the VPC, subnet, internet gateway, route table, security group, and EC2 instance.

## Customization Ideas

- Add a private subnet and NAT gateway for a multi-tier topology.
- Replace the single instance with an Auto Scaling group + load balancer.
- Wire the modules into a CI/CD pipeline for consistent provisioning.