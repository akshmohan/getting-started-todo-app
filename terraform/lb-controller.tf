# =============================================================================
# AWS Load Balancer Controller - IAM policy + EKS Pod Identity
#
# Uses EKS Pod Identity (newer than IRSA). The eks-pod-identity-agent
# DaemonSet provides credentials directly — no OIDC, no webhook required.
# =============================================================================

resource "aws_iam_policy" "lb_controller" {
  name        = "todo-eks-lb-controller"
  description = "IAM policy for the AWS Load Balancer Controller"

  policy = file("${path.module}/lb-controller-policy.json")

  tags = {
    Project     = "getting-started-todo-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "aws-load-balancer-controller"
  }
}

# ---- IAM role with Pod Identity trust (not OIDC) ----
resource "aws_iam_role" "lb_controller" {
  name        = "todo-eks-lb-controller-pod-identity"
  description = "Role assumed by the AWS Load Balancer Controller via EKS Pod Identity"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })

  tags = {
    Project     = "getting-started-todo-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "aws-load-balancer-controller"
  }
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

# ---- The Pod Identity Association ----
resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = "todo-eks"
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller.arn
}