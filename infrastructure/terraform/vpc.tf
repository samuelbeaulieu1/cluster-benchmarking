module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-cluster-benchmark"

  cidr = "10.0.0.0/16"

  azs             = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
  private_subnets = ["10.0.0.0/24",  "10.0.1.0/24" ]
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "vpc-id" {
  description = "The VPC id"
  value = module.vpc.vpc_id
}

output "vpc-subnets-id" {
  description = "List of the VPC private subnetworks IDs"
  value = module.vpc.private_subnets
}