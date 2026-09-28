terraform {
  backend "s3" {
    bucket         = "todo-eks-tfstate-015048356322"
    key            = "todo-eks/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "todo-eks-tfstate-lock"
    encrypt        = true
  }
}
