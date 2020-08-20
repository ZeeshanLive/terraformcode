resource "aws_vpc" "app_vpc" {
cidr_block = var.appvpc
tags = {
"Name" = "${var.environment}-appvpc"
"Environment" = "${var.environment}"
}

}

resource "aws_subnet" "bastion" {
  availability_zone = data.aws_availability_zones.available.names[2]
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.bastionsubnet
  tags = {
  "Name" = "${var.environment}-BastionSubnet"
  "Environment" = "${var.environment}"
}
}

resource "aws_subnet" "appsubnet1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.appsubnet1
  tags = {
  "Name" = "${var.environment}-AppSubnet1"
  "Environment" = "${var.environment}"
}
}



resource "aws_subnet" "appsubnet2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.appsubnet2

    tags = {
   "Name" = "${var.environment}-AppSubnet2"
  "Environment" = "${var.environment}"
}
}



resource "aws_subnet" "dbsubnet" {
  availability_zone = data.aws_availability_zones.available.names[2]
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = var.dbsubnet

      tags = {
  "Name" = "${var.environment}-DbSubnet"
  "Environment" = "${var.environment}"
}
}

##Routing


resource "aws_eip" "nateip" {
  vpc      = true

  tags = {
    Name = "${var.environment}-App-eip"
    "Environment" = "${var.environment}"

  }
}

resource "aws_eip" "vpneip" {
  vpc      = true

  tags = {
    Name = "${var.environment}-vpn-eip"
    "Environment" = "${var.environment}"

  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.appsubnet1.id
    tags = {
    Name = "${var.environment}-App-natgw"
    "Environment" = "${var.environment}"

  }
}

resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.environment}-App-IGW"
    "Environment" = "${var.environment}"

  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.app_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }


  tags = {
    Name = "${var.environment}-Public-RouteTable"
    "Environment" = "${var.environment}"
  }
}


resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.app_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

    route {
    cidr_block = var.dtvpc
    vpc_peering_connection_id = aws_vpc_peering_connection.app_dt_peering.id
  }



  tags = {
    Name = "${var.environment}-PrivateRouteTable"
    "Environment" = "${var.environment}"
  }
}

resource "aws_route_table_association" "PublicRouteTableAssociation" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = aws_route_table.PublicRouteTable.id
}



resource "aws_route_table_association" "PrivateRouteTableAssociation" {
  count = length(var.appsubnetassociation)
  subnet_id      = element(var.appsubnetassociation, count.index)
  route_table_id = aws_route_table.PrivateRouteTable.id
}

##DynatraceResources

resource "aws_vpc" "dt_vpc" {
cidr_block = var.dtvpc
tags = {
"Name" = "${var.environment}-DTVPC"
"Environment" = "${var.environment}"
}
}


resource "aws_subnet" "dtsubnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id     = aws_vpc.dt_vpc.id
  cidr_block = var.dtsubnet

      tags = {
  "Name" = "${var.environment}-DTSubnet"
  "Environment" = "${var.environment}"
}
}


resource "aws_vpc_peering_connection" "app_dt_peering" {
  peer_vpc_id   = aws_vpc.dt_vpc.id
  vpc_id        = aws_vpc.app_vpc.id
  auto_accept   = true

  tags = {
  "Name" = "${var.environment}-app_dt_peering"
  "Environment" = "${var.environment}"
}
}


resource "aws_route_table" "DynatraceRouteTable" {
  vpc_id = aws_vpc.dt_vpc.id

  #   route {
  #   cidr_block = 
  #   nat_gateway_id = aws_nat_gateway.natgw.id
  # }

    route {
    cidr_block = var.appvpc
    vpc_peering_connection_id = aws_vpc_peering_connection.app_dt_peering.id
  }



  tags = {
    Name = "${var.environment}-DTRouteTable"
    "Environment" = "${var.environment}"
  }
}


resource "aws_route_table_association" "DynatraceRouteTableAssociation" {
  subnet_id      = aws_subnet.dtsubnet.id
  route_table_id = aws_route_table.DynatraceRouteTable.id
}


####Outputs


output "azs" {
  value = data.aws_availability_zones.available.names
}

output "AppServerSubnets" {
  value = [aws_subnet.appsubnet1.id,aws_subnet.appsubnet2.id]
}

output "appvpc" {
  value = aws_vpc.app_vpc.id
}


output "vpnsubnet" {
  value = aws_subnet.bastion.id
}

output "dbsubnet" {
  value = aws_subnet.dbsubnet.id
}

output "dtvpc" {
  value = aws_vpc.dt_vpc.id
}

output "dtsubnet" {
  value = aws_subnet.dtsubnet.id
}

output "vpneip" {
  value = aws_eip.vpneip.id
}