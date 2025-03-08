# main.tf - AWS provider and high-level resources
provider "aws" {
  region = "eu-west-1" 
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "flask-cluster"
}
