#-------------------
# VPC
#-------------------
resource "aws_vpc" "default" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "default"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

#-------------------
# Public Subnets
#-------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = element(var.public_subnet_cidrs,count.index)
  availability_zone       = element(var.subnet_availability_zones,count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-%s", element(var.subnet_availability_zones,count.index))
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public.id
}

#-------------------
# Private Subnets
#-------------------
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = element(var.private_subnet_cidrs,count.index)
  availability_zone       = element(var.subnet_availability_zones,count.index)
  map_public_ip_on_launch = true
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.default.id

  tags = {
    Name = format("private-%d", "${count.index}")
  }

}

resource "aws_eip" "private" {
  count = length(var.private_subnet_cidrs)
  vpc = true
}

resource "aws_nat_gateway" "private" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = element(aws_eip.private.*.id,count.index)
  subnet_id     = element(aws_subnet.private.*.id,count.index)
}

resource "aws_route" "private" {
  count                  = length(var.private_subnet_cidrs)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = element(aws_nat_gateway.private.*.id, count.index)
}


resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private.*.id,count.index)
  route_table_id = element(aws_route_table.private.*.id,count.index)
}

#-------------------
# Network ACL
#-------------------
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.default.id
  subnet_ids   = aws_subnet.public.*.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "public"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.default.id
  subnet_ids   = aws_subnet.private.*.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "private"
  }
}

