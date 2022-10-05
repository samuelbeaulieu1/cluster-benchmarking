resource "aws_iam_policy" "policy" {
  name        = "ec2-policy"
  description = "ec2 ecr policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GrantSingleImageReadOnlyAccess",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ],
        "Resource" : "arn:aws:ecr:us-east-1:${data.aws_caller_identity.this.account_id}:repository/8415-ecr-repo"
      },
      {
        "Sid" : "GrantECRAuthAccess",
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = "LabRole"
}

resource "aws_iam_policy_attachment" "ec2-policy-attach" {
  name       = "ec2-policy-attach"
  roles      = ["LabRole"]
  policy_arn = aws_iam_policy.policy.arn
}