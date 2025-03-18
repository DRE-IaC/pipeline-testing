##
# velero.tf All the resources required for velero role to work
# Eventually will be migrated from terraform to crossplane
##

resource "aws_s3_bucket" "velero" {
  bucket_prefix = "${local.prefix}velero"

  tags = {
    repository  = "infrastructure-controlplane"
    product = "velero"
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for velero to be able to publish config backups in S3
resource "aws_iam_role" "dre_iac_velero" {
  name        = "${local.prefix}dre-iac-velero" 
  description = "Role for velero to be able to publish config backups to S3"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = "${module.dre_crossplane_primary_1.oidc_provider_arn}"
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.dre_crossplane_primary_1.oidc_provider}:aud" = "sts.amazonaws.com",
            "${module.dre_crossplane_primary_1.oidc_provider}:sub": "system:serviceaccount:velero:velero-server"
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    owner = "dre-iac"
  })
}

resource "aws_iam_policy" "velero" {
  name        = "${local.prefix}dre_iac_velero"
  description = "Allows velero to publish to and read S3"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action  = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
      Effect    = "Allow",
      Resource  = "*"
      }]
  })
}

# velero role attachment
resource "aws_iam_policy_attachment" "dre_iac_velero" {
  name       = "dre_iac_github_actions_eks_access_policy_attachment"
  roles      = [aws_iam_role.dre_iac_velero.name]
  policy_arn = aws_iam_policy.velero.arn
}