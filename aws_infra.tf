


###################################################################################################################################################################################################

#######################################
####
#### VPC Creation
####
#######################################




# Define the VPC and subnet CIDRs
variable "vpccidrs" {
  default = ["10.5.0.0/21"]
}

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c", "${var.aws_region}d"]
}





# Create the VPC
resource "aws_vpc" "default" {
  count      = 1
  cidr_block = var.vpccidrs[count.index]

  tags = {
    Name = "egress-demo-vpc-${count.index + 1}"
  }
}



###################################################################################################################################################################################################

#######################################
####
#### IGW Creation
####
#######################################




# Create the internet gateway
resource "aws_internet_gateway" "default" {
  count  = 1
  vpc_id = aws_vpc.default[count.index].id

  tags = {
    Name = "egress-demo-igw-${count.index + 1}"
  }
}



###################################################################################################################################################################################################


#######################################
####
#### SUBNETS Creation
####
#######################################



# Create the public subnets VPC1
resource "aws_subnet" "public_vpc1" {
  count             = var.number_of_azs
  cidr_block        = cidrsubnet(var.vpccidrs[0], 3, count.index)
  vpc_id            = aws_vpc.default[0].id
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name        = "vpc1-public-${local.availability_zones[count.index]}"
    Subnet-Type = "Public"
  }
}

# Create the private subnets VPC1
resource "aws_subnet" "private_vpc1" {
  count             = var.number_of_azs
  cidr_block        = cidrsubnet(var.vpccidrs[0], 3, count.index + var.number_of_azs)
  vpc_id            = aws_vpc.default[0].id
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name        = "vpc1-private-${local.availability_zones[count.index]}"
    Subnet-Type = "Private"
  }
}



###################################################################################################################################################################################################

#######################################
####
####  NAT GW Creation
####
#######################################




# Create the EIPs for the NAT gateways
resource "aws_eip" "natgws" {
  count = var.number_of_azs
  vpc   = true
  tags = {
    Name = "natgw-eip-${count.index}"
  }
}





# Create the NAT gateways for VPC1
resource "aws_nat_gateway" "vpc1" {
  count = var.number_of_azs

  allocation_id = aws_eip.natgws[count.index].id
  subnet_id     = aws_subnet.public_vpc1[count.index].id

  tags = {
    Name = "natgw-vpc1-${local.availability_zones[count.index]}"
  }
}







###################################################################################################################################################################################################

#######################################
####
#### RT Creation
####
#######################################



# Create the route tables for VPC1 without a TGW

resource "aws_route_table" "vpc1_public" {
  count  = var.number_of_azs
  vpc_id = aws_vpc.default[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default[0].id
  }

  tags = {
    Name = "vpc1-public-rt-${local.availability_zones[count.index]}"
  }

  lifecycle {
    ignore_changes = [route, ]
  }

}

resource "aws_route_table" "vpc1_private" {
  count  = var.number_of_azs
  vpc_id = aws_vpc.default[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc1[count.index].id
  }

  tags = {
    Name = "vpc1-private-rt-${local.availability_zones[count.index]}"
  }

  lifecycle {
    ignore_changes = [route, ]
  }
}





# Associate the subnets with the route tables for VPC1
resource "aws_route_table_association" "public_vpc1" {
  count = var.number_of_azs

  subnet_id      = aws_subnet.public_vpc1[count.index].id
  route_table_id = aws_route_table.vpc1_public[count.index].id
}

resource "aws_route_table_association" "private_vpc1" {
  count = var.number_of_azs

  subnet_id      = aws_subnet.private_vpc1[count.index].id
  route_table_id = aws_route_table.vpc1_private[count.index].id
}








