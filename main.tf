provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "quest-app" {
  ami           = "ami-0ba9883b710b05ac6" # Update with the latest Node.js AMI
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    docker run -d -e SECRET_WORD=${SECRET_WORD} -p 80:80 my-node-app
  EOF
}

resource "aws_elb" "quest-lb" {
    name               = "quest-loadbalancer"
    availability_zones = ["us-east-1a"]
    listener {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port = 80
        lb_protocol = "HTTP"
    }
    health_check {
        target              = "HTTP:80/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
    instances = [aws_instance.quest-app.id]
    
}
