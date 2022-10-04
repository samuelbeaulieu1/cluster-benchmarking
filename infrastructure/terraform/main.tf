data "aws_region" "current" {}

# get access to aws acc ID, user ID arn
data "aws_caller_identity" "this" {}

# retrieves authorization token, proxy endpoint, token expiration date,
# user name and password to be retrieved for an ECR repository.
data "aws_ecr_authorization_token" "token" {}

# Configure the Providers
provider "aws" {
  region  = "us-east-1"
}

provider "docker" {
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

locals {
  app_id = "8415-assignment-01"
}

# External module used to build docker images and push them to ECR
module "lambda_docker-build" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "4.0.2"
}








