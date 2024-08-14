# main.tf

provider "aws" {
  region = "us-east-1"
}

# Create a security group
resource "aws_security_group" "app_sg" {
  name_prefix = "app-"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "app_instance" {
  ami           = "ami-0e36db3a3a535e401" # Amazon Linux 2 AMI (update as needed)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "rearc-quest"
  }
}

# Create an Elastic Load Balancer
resource "aws_elb" "app_lb" {
  name               = "app-lb"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol = "HTTP"
  }

  listener {
    instance_port     = 443
    instance_protocol = "HTTPS"
    lb_port           = 443
    lb_protocol = "HTTPS"
    ssl_certificate_id = aws_acm_certificate.app_cert.arn
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  instances = [aws_instance.app_instance.id]
}

# Create an ACM certificate (for production use, replace with your own cert)
resource "aws_acm_certificate" "app_cert" {
  domain_name       = "rearcquest.com"
  validation_method = "DNS"
}

# Output the load balancer URL
output "elb_url" {
  value = aws_elb.app_lb.dns_name
}
