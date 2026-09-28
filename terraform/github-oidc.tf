# =============================================================================
# GitHub Actions OIDC -> AWS IAM Role
#
# Allows GitHub Actions workflows in this repo to assume an IAM role in this
# AWS account WITHOUT storing any static AWS credentials in GitHub.
# =============================================================================

# -----------------------------------------------------------------------------
# The OIDC provider for GitHub Actions
# -----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Project     = "getting-started-todo-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "github-actions-oidc"
  }
}

# -----------------------------------------------------------------------------
# IAM role assumed by GitHub Actions workflows in this repo
# -----------------------------------------------------------------------------
resource "aws_iam_role" "github_actions" {
  name        = "todo-app-github-actions"
  description = "Assumed by GitHub Actions workflows in akshmohan/getting-started-todo-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:akshmohan/getting-started-todo-app:*"
          }
        }
      }
    ]
  })

  tags = {
    Project     = "getting-started-todo-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "github-actions-ci"
  }
}

# -----------------------------------------------------------------------------
# Policy: ECR push access to the two app repos
# -----------------------------------------------------------------------------
resource "aws_iam_policy" "github_actions_ecr" {
  name        = "todo-app-github-actions-ecr"
  description = "Allow GitHub Actions to push images to ECR repos for the todo app"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = [
          "arn:aws:ecr:ap-south-1:015048356322:repository/todo-backend",
          "arn:aws:ecr:ap-south-1:015048356322:repository/todo-client"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}
