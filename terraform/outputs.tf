output "github_actions_role_arn" {
  description = "ARN of the IAM role that GitHub Actions assumes via OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "ecr_backend_repo_url" {
  description = "ECR repo URL for the backend image"
  value       = "015048356322.dkr.ecr.ap-south-1.amazonaws.com/todo-backend"
}

output "ecr_client_repo_url" {
  description = "ECR repo URL for the client image"
  value       = "015048356322.dkr.ecr.ap-south-1.amazonaws.com/todo-client"
}

output "lb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller (via EKS Pod Identity)"
  value       = aws_iam_role.lb_controller.arn
}

