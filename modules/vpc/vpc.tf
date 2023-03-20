resource "aws_vpc" "main-vpc" {
  cidr_block       = var.cidr_blocks
  instance_tenancy = "default"
  tags             = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "vpc") })
}

resource "aws_subnet" "public_sub" {
  count                   = length(var.public_cidr_blocks)
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.public_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(var.tags, { Name = format("public-%s-%s-%s", "subnet", var.appname, var.env) })
}


resource "aws_subnet" "private_sub" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags              = merge(var.tags, { Name = format("private-${var.name_prefix[floor(count.index / 2)]}-${count.index % 2 + 1}-%s-%s-server", var.appname, var.env) })
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main-vpc.id
  tags   = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "gateway") })
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags   = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "pub-route") })
  route {
    cidr_block = var.cidr_blocks_defualt
    gateway_id = aws_internet_gateway.gateway.id
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route_table_association" "public-sub-asso" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = element(aws_subnet.public_sub.*.id, count.index)
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_eip" "elasticip" {
  vpc  = true
  tags = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "eip") })
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.public_sub[0].id
  tags          = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "nat-gateway") })
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main-vpc.id
  tags   = merge(var.tags, { Name = format("%s-%s-%s", var.appname, var.env, "private-route") })
  route {
    cidr_block = var.cidr_blocks_defualt
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_route_table_association" "private-sub-asso" {
  count          = length(var.private_cidr_blocks)
  subnet_id      = element(aws_subnet.private_sub.*.id, count.index)
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_security_group" "main-sg" {
  name   = "main-sg"
  vpc_id = aws_vpc.main-vpc.id

  dynamic "ingress" {
    for_each = [80, 8080, 3306, 22]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr_blocks_defualt]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks_defualt]
  }

  tags = {
    "Name" = "main-sg"
  }
}
