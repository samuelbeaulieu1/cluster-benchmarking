data "aws_region" "current" {}

# get access to aws acc ID, user ID arn
data "aws_caller_identity" "this" {}

# retrieves authorization token, proxy endpoint, token expiration date,
# user name and password to be retrieved for an ECR repository.
data "aws_ecr_authorization_token" "token" {}

# Configure the Providers
provider "aws" {
  region = "us-east-1"
}

provider "docker" {
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

locals {
  app_id        = "8415-assignment-01"
  build_version = "1.0.0"
  ubuntu_ami    = "ami-08c40ec9ead489470"

  cluster1_group_keys = toset(["1", "2", "3", "4", "5"])
  cluster2_group_keys = toset(["6", "7", "8", "9"])
}

# External module used to build docker images and push them to ECR
module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "8415-ecr-repo"
  image_tag       = local.build_version
  source_path     = "../../app/"
}

module "ec2_instance-medium" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.cluster1_group_keys

  name = "instance-${each.key}"

  ami                         = local.ubuntu_ami
  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name

  tags = {
    Terraform       = "true"
    Environment     = "dev"
    Instance_number = "${each.key}"
  }
}

module "ec2_instance-large" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.cluster2_group_keys

  name = "instance-${each.key}"

  ami                         = local.ubuntu_ami
  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id]
  subnet_id                   = module.vpc.private_subnets[1]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name

  tags = {
    Terraform       = "true"
    Environment     = "dev"
    Instance_number = "${each.key}"
  }
}





