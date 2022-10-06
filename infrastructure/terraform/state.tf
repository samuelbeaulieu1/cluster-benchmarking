# file used to create ressources for backend see
# https://www.terraform.io/language/settings/backends/configuration for details

# On first run comment this section to create bucket locally, then uncomment to  set bucket as backend
###### BEGIN
terraform {
  backend "s3" {
    bucket         = "8415-assignment-001-terraform-state-01"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/8415-assignment-001-terraform-bucket-key"
    dynamodb_table = "8415-assignment-001-terraform-state"
  }
}
###### END

#############################################
# KMS (used to encrypt state bucket)
#############################################
resource "aws_kms_key" "terraform_bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/8415-assignment-001-terraform-bucket-key"
  target_key_id = aws_kms_key.terraform_bucket_key.key_id
}

#############################################
# S3 Bucket (used to store tf state)
#############################################
resource "aws_s3_bucket" "terraform_state" {
  bucket = "8415-assignment-001-terraform-state-01"
}

resource "aws_s3_bucket_acl" "tf_state_bucket_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_bucket_encryption_config" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_bucket_pub_access_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#############################################
# DynamoDB (used to lock tf state)
#############################################
resource "aws_dynamodb_table" "terraform_state" {
  name           = "8415-assignment-001-terraform-state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
