resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true


  tags = local.common_tags
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = local.common_tags
}

resource "aws_subnet" "public" {
    count = length(var.public_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidrs[count.index]


  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-public"
    }
  )
}

resource "aws_subnet" "private" {
    count = length(var.private_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidrs[count.index]


  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-private"
    }
  )
}

resource "aws_subnet" "database" {
    count = length(var.database_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidrs[count.index]

   tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-database"
    }
  )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-public"
    }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-private"
    }
  )
}

resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.env}-database"
    }
  )
}

resource "aws_route_table_association" "public_assoc" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "database_assoc" {
  count = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database_rt.id
}

# 1. Allocate an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # Required to allocate the EIP within your VPC

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.env}-nat-eip"
    }
  )
}

# 2. Create the NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Must be placed in a PUBLIC subnet

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.env}-nat-gw"
    }
  )

  # Explicit dependency to ensure proper creation and deletion order
  depends_on = [aws_internet_gateway.main]
}



