###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################


# ____   ____            .__      ___.   .__                 
# \   \ /   /____ _______|__|____ \_ |__ |  |   ____   ______
#  \   Y   /\__  \\_  __ \  \__  \ | __ \|  | _/ __ \ /  ___/
#   \     /  / __ \|  | \/  |/ __ \| \_\ \  |_\  ___/ \___ \ 
#    \___/  (____  /__|  |__(____  /___  /____/\___  >____  >
#                \/              \/    \/          \/     \/ 


###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################


#######################################
####
#### Main Variables Creation
####
#######################################

variable "aviatrix_username" {
  description = "Aviatrix Controller admin username"
  type        = string
}

variable "aviatrix_controller_ip" {
  description = "IP address of the Aviatrix Controller"
  type        = string
}

variable "aviatrix_password" {
  description = "Aviatrix Controller admin password"
  type        = string
  sensitive   = true  # Marking it as sensitive to hide it in logs
}

#variable "aws_profile" {
#  description = "The AWS profile to use for authentication"
#  type        = string
#}

#variable "aws_credentials_path" {
#  description = ".aws/credentials"
#  default     = "~/.aws/credentials"
#}

#variable "aws_access_key" {
#  description = "AWS access key for authentication"
#  type        = string
#  sensitive   = true
#}

#variable "aws_secret_key" {
#  description = "AWS secret key for authentication"
#  type        = string
#  sensitive   = true
#}


variable "aws_spoke1_name" {
  default = "aws-egress1"
}

variable "aviatrix_aws_account_name" {
  description = "Aviatrix AWS Account Name"
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

# variable "aws_key_pair_name" {
#   description = "AWS Key Pair Name"
# }

variable "avx_gateway_size" {
  description = "Instance size for the Aviatrix gateways"
  default = "t3.micro"
  
}

variable "number_of_azs" {
  description = "Number of Availability Zones in each VPC"
  default = 2
}

variable "deploy_avx_egress_gateways" {
  type = bool
  description = "Stage the deployment of Aviatrix Gateways in VPC 1"
  default = true
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed."
  type        = map(string)

  default = {
    avxlab = "microseg"
  }
}





###################################################################################################################################################################################################

#######################################
####
#### Booleans Creation
####
#######################################


# variable "deploy_aws_tgw" {
#   type = bool
#   description = "Deploys a second VPC and a TGW to attach to the VPC.  This is to demonstrate seamless integration of Aviatrix Secure Egress into an existing transit architecture."
#   default = false
# }

# variable "deploy_aviatrix_transit" {
#   type = bool
#   description = "Deploys a second VPC and a TGW to attach to the VPC.  This is to demonstrate seamless integration of Aviatrix Secure Egress into an existing transit architecture."
#   default = false
# }

variable "deploy_aws_workloads" {
  type = bool
  description = "Deploy workloads in the AWS VPCs for testing connectivity and FQDN filtering."
  default = true
}

# variable "deploy_dfw_egress_policy" {
#   type = bool
#   description = "Deploy a Aviatrix Secure Egress configuration leveraging Egress 2.0."
#   default = false
# }

# variable "deploy_avx_egress_policy" {
#   type = bool
#   description = "Deploy a Aviatrix Secure Egress configuration leveraging the legacy FQDN Egress policy configuration."
#   default = false
# }

# variable "enable_nat_avx_egress_gateways" {
#   type = bool
#   description = "Enable NAT on the Aviatrix Egress Gateways"
#   default = false
# }

