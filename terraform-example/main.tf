# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Data source: query the list of availability zones
data "aws_availability_zones" "all" {
  state = "available"
}

# Create a Security Group for an EC2 instance
resource "aws_security_group" "instance-ssh" {
  name = "terraform-ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-wp-instance-http"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a Security Group for an ELB
resource "aws_security_group" "elb" {
  name = "terraform-project-elb"

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create a Launch Configuration
resource "aws_launch_configuration" "project" {
  name_prefix = "http-server-0"
  #image_id        = "ami-785db401"
  image_id = "ami-0f88ff1e346fc8970"
  #ami aws with nginx 
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
  !/bin/bash
              echo "Hello, World" > /var/www/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Create an Autoscaling Group
resource "aws_autoscaling_group" "project" {
  launch_configuration = aws_launch_configuration.project.id
  availability_zones   = ["${data.aws_availability_zones.all.names[0]}"]
  load_balancers       = ["${aws_elb.project.name}"]
  health_check_type    = "ELB"
  min_size             = 2
  max_size             = 4

  tag {
    key                 = "Name"
    value               = "terraform-asg-project"
    propagate_at_launch = true
  }
}

# Create an ELB
resource "aws_elb" "project" {
  name               = "terraform-asg-project"
  availability_zones = ["${data.aws_availability_zones.all.names[0]}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}
