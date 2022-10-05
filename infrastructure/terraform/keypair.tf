module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = local.app_id
  create_private_key = true
}

output "private-key" {
  description = "Private key data in OpenSSH PEM (RFC 4716) format"
  value       = module.key_pair.private_key_openssh
  sensitive   = true
}

output "public-key" {
  description = "Private key data in OpenSSH PEM (RFC 4716) format"
  value       = module.key_pair.public_key_openssh
}

output "key-pair-name" {
  description = "Key pair name"
  value = module.key_pair.key_pair_name
}