resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow HTTP/HTTPS access to ALB"

  ingress {
    description = "Allow port 80 TCP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.trusted_ip_range] # Use a specific IP range (e.g., "192.168.1.0/24")
  }

  ingress {
    description = "Allow port 443 TCP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.trusted_ip_range] # Use a specific IP range (e.g., "192.168.1.0/24")
  }

  egress {
    description = "Allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.trusted_ip_range] # Restrict outbound traffic to a trusted network
  }
}

resource "aws_security_group" "app" {
  name        = "ecs-service-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow inbound access to ECS service from ALB only"

  ingress {
    description = "Allow port 5000 TCP"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.trusted_ip_range] # Restrict outbound traffic to a trusted network
  }
}
