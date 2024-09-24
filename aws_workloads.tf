###################################################################################################################################################################################################

#######################################
####
#### SSH Key Creation
####
#######################################

module "key_pair" {
  count  = var.deploy_aws_workloads ? 1 : 0
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "secure_egress_${random_string.name.result}"
  create_private_key = true
}



###################################################################################################################################################################################################

#######################################
####
#### SG Creation
####
#######################################



resource "aws_security_group" "allow_all_rfc1918" {
  count       = 1
  name        = "allow_all_rfc1918_vpc${count.index + 1}"
  description = "allow_all_rfc1918_vpc${count.index + 1}"
  vpc_id      = aws_vpc.default[count.index].id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_rfc1918_vpc${count.index + 1}"
  }
}




resource "aws_security_group" "allow_web_ssh_public" {
  count       = 1
  name        = "allow_web_ssh_public"
  description = "allow_web_ssh_public"
  vpc_id      = aws_vpc.default[0].id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 83
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web_ssh_public"
  }
}





###################################################################################################################################################################################################

#######################################
####
#### AMI Definition
####
#######################################


data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}



###################################################################################################################################################################################################

#######################################
####
#### Workload Creation
####
#######################################



## Wait for NAT GW's to be ready before deploying private workloads
resource "time_sleep" "egress_ready" {
  depends_on = [aws_nat_gateway.vpc1]

  create_duration = "90s"
}

## Deploy Linux Test Hosts in VPC1, All AZs running Gatus for connectivity testing
module "ec2_instance_vpc1" {
  count  = var.number_of_azs
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "vpc1-workload-${count.index}"

  ami                         = data.aws_ami.amazon-linux-2.image_id
  instance_type               = "t3a.micro"
  key_name                    = module.key_pair[0].key_pair_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.allow_all_rfc1918[0].id]
  subnet_id                   = aws_subnet.private_vpc1[count.index].id
  user_data                   = templatefile("${path.module}/vpc1_test_server.tftpl", { az = "${count.index + 1}" })
  user_data_replace_on_change = true

  tags = {
    OS = "Linux"
    Application = "HealthMonitor"
  }

  depends_on = [
    aws_route_table_association.private_vpc1
  ]
#   lifecycle {
#     ignore_changes = [ami, ]
#   }

}


###################################################################################################################################################################################################

#######################################
####
#### ELB Creation
####
#######################################



# Deploy an ELB to enable public access to web portal on the test Linux servers in VPC1
resource "aws_lb" "test-machine-ingress" {
  count              = var.deploy_aws_workloads ? 1 : 0
  name               = "avx-secure-egress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web_ssh_public[0].id]
  subnets            = [for v in aws_subnet.public_vpc1 : v.id]
}

resource "aws_lb_listener" "test-machine-ingress" {
  count             = var.deploy_aws_workloads ? var.number_of_azs : 0
  load_balancer_arn = aws_lb.test-machine-ingress[0].arn
  port              = "8${count.index}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-machine-ingress[count.index].arn
  }
}

resource "aws_lb_target_group" "test-machine-ingress" {
  count       = var.deploy_aws_workloads ? var.number_of_azs : 0
  name        = "test-machine-${count.index}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.default[0].id
  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200,302" # has to be HTTP 200 or fails
  }
}

resource "aws_lb_target_group_attachment" "test-machine-ingress" {
  count            = var.deploy_aws_workloads ? var.number_of_azs : 0
  target_group_arn = aws_lb_target_group.test-machine-ingress[count.index].arn
  target_id        = module.ec2_instance_vpc1[count.index].private_ip
  port             = 80
}

output "lb_dns_name1" {
  value = "http://${aws_lb.test-machine-ingress[0].dns_name}:80/"
}

output "lb_dns_name2" {
  value = "http://${aws_lb.test-machine-ingress[0].dns_name}:81/"
}

