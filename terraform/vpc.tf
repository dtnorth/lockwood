module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "flask-app-vpc"
  cidr   = "10.0.0.0/16"

  azs             = var.aws_availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false
}
