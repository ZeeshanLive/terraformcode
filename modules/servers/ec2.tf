

resource "aws_security_group" "vpn_sg" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = var.appvpc

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-Db security group"
    "Environment" = "${var.environment}"
  }
}



resource "aws_security_group" "DB_sg" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = var.appvpc

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-Db security group"
    "Environment" = "${var.environment}"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = var.appvpc

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-app security group"
    "Environment" = "${var.environment}"
  }
}


resource "aws_security_group" "DT_sg" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = var.appvpc

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-DT security group"
    "Environment" = "${var.environment}"
  }
}


resource "aws_security_group" "allow_albsg" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = var.appvpc

  ingress {
    description = "TLS from VPC"
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

  tags = {
    Name = "${var.environment}-alb security group"
    "Environment" = "${var.environment}"
  }
}

resource "aws_lb" "AppLoadBalancer" {
  name               = "${var.environment}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_albsg.id]
  subnets            = var.appsubnets

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Name = "${var.environment}-app-alb"
    "Environment" = "${var.environment}"
  }
}


resource "aws_launch_configuration" "AppLaunchconf" {
  name_prefix   = "${var.environment}-app-launch-configuaration"
  image_id      = var.appamiid
  instance_type = var.appinstancesize
  key_name = var.keyname
  security_groups = [aws_security_group.app_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app-asg" {
  name                 = "${var.environment}-app-asg"
  launch_configuration = aws_launch_configuration.AppLaunchconf.name
  min_size             = 1
  max_size             = 2
  target_group_arns = [aws_alb_target_group.app-target-group.arn]
  vpc_zone_identifier  = var.appsubnets
    health_check_type = "ELB"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "app-target-group" {
  name = "${var.environment}-app-targetgroup"
  vpc_id = var.appvpc
  port = 80
  protocol = "HTTP"
  health_check {
    path = "/"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }
}

resource "aws_alb_listener" "app-alb-listener" {
  default_action {
    target_group_arn = aws_alb_target_group.app-target-group.arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.AppLoadBalancer.arn
  port = 80
  protocol = "HTTP"
}


resource "aws_instance" "vpn" {
  ami           = var.vpnami
  instance_type = var.vpninstancesize
  key_name = var.keyname
  subnet_id = var.vpnsubnet
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]

  tags = {
    Name = "${var.environment}-vpn"
    "Environment" = "${var.environment}"
  }
}

resource "aws_eip_association" "vpn_eip_assoc" {
  instance_id   = aws_instance.vpn.id
  allocation_id = var.vpneip
}


resource "aws_instance" "db" {
  ami           = var.dbami
  instance_type = var.dbinstancesize
  subnet_id = var.dbsubnet
  key_name = var.keyname
  vpc_security_group_ids = [aws_security_group.DB_sg.id]

  tags = {
    Name = "${var.environment}-db"
    "Environment" = "${var.environment}"
  }
}

resource "aws_instance" "dt" {
  ami           = var.dtami
  instance_type = var.dtinstancesize
  key_name = var.keyname
  subnet_id = var.dtsubnet
  vpc_security_group_ids = [aws_security_group.DT_sg.id]

  tags = {
    Name = "${var.environment}-dt"
    "Environment" = "${var.environment}"
  }
}