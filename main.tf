###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################


#_________ .__                   .___ __________             .__                __                   _________                          .__  __          
#\_   ___ \|  |   ____  __ __  __| _/ \______   \ ___________|__| _____   _____/  |_  ___________   /   _____/ ____   ____  __ _________|__|/  |_ ___.__.
#/    \  \/|  |  /  _ \|  |  \/ __ |   |     ___// __ \_  __ \  |/     \_/ __ \   __\/ __ \_  __ \  \_____  \_/ __ \_/ ___\|  |  \_  __ \  \   __<   |  |
#\     \___|  |_(  <_> )  |  / /_/ |   |    |   \  ___/|  | \/  |  Y Y  \  ___/|  | \  ___/|  | \/  /        \  ___/\  \___|  |  /|  | \/  ||  |  \___  |
# \______  /____/\____/|____/\____ |   |____|    \___  >__|  |__|__|_|  /\___  >__|  \___  >__|    /_______  /\___  >\___  >____/ |__|  |__||__|  / ____|
#        \/                       \/                 \/               \/     \/          \/                \/     \/     \/                       \/     


###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################

### This code will deploy a VPC in AWS with 2 Linux workloads running Gatus
### It can also deploy an Aviatrix Spoke gateway for egress if you choose to (default is to deploy). This is to accelerate the demo process.
###
### Before running, please note the following:
###
### 1. Update the AWS Provider with your credentials information
### 2. Update the tfvars file to your required inputs if you choose to use tfvars
### 3. You can modify the Gatus config in the vpc1_test_server.tftpl file if you so wish (recommend to use it as is)
### 4. If you run without tfvars, you will be prompted for your AWS account name, controller ip and credentials
### 5. The code will output the loadbalancer URL for the 2 workloads. It's the same URL with port 80 and port 81
###

###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################


terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = ">=3.0"
    }
   aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ssh = {
      source = "loafoe/ssh"
    }
  }
}

# Data source to fetch the AviatrixController instance by tag
#data "aws_instance" "aviatrix_controller" {
#  filter {
#    name   = "tag:Name"  # Filter by the Name tag
#    values = ["AviatrixController"]  # The tag value for the Controller instance
#  }
#}

# Output the public IP of the Aviatrix Controller
#output "controller_public_ip" {
#  value = data.aws_instance.aviatrix_controller.public_ip
#}

# Local variable to store the public IP
#locals {
#  controller_ip = data.aws_instance.aviatrix_controller.public_ip
#}

provider "aviatrix" {
  skip_version_validation = true
  username = var.aviatrix_username
  #controller_ip = local.controller_ip
  controller_ip = var.aviatrix_controller_ip
  password = var.aviatrix_password
}




provider "aws" {
  region = var.aws_region
  # shared_credentials_files = ["~/.aws/credentials"]
  # profile = "SubAccountAdmin-535708457972"
  # profile = var.aws_profile  # Use the aws_profile variable here
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
}

// Generate random value for the name
resource "random_string" "name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
}


data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
