# =============================================================================
# Remote state backend resources (S3 + DynamoDB)
#
# These are created MANUALLY (with local state) the FIRST time, then Terraform
# migrates to using them. This avoids the chicken-and-egg problem.
# =============================================================================

locals {
  state_bucket_name = "todo-eks-tfstate-015048356322"
  state_lock_table  = "todo-eks-tfstate-lock"
}

# -----------------------------------------------------------------------------
# S3 bucket for Terraform state
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket_name

  tags = {
    Project     = "getting-started-todo-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "terraform-remote-state"
  }

  # NOTE: prevent_destroy is intentionally false for this learning project.
  # The state bucket gets destroyed along with everything else on `terraform destroy`
  # and recreated on the next `terraform apply`. For production, set this to true.

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# DynamoDB table for state locking (prevents concurrent applies)
# -----------------------------------------------------------------------------
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = local.state_lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = "getting-started-todo-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "terraform-state-lock"
  }
}
