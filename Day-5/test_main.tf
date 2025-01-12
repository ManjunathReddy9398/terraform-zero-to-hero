provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "myvpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-2a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-2a"
    map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "my_Ig" {
    vpc_id = aws_vpc.myvpc.id
}

resource "aws_eip" "my_eip" {
    vpc = true
}

resource "aws_nat_gateway" "my_NatG" {
    allocation_id = aws_eip.my_eip.id
    subnet_id = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_route_table" {    
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_NatG.id
    }
}

resource "aws_route_table_association" "private_rt" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_Ig.id
    }
}

resource "aws_route_table_association" "public_rt" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "my_PublicSG" {
    vpc_id = aws_vpc.myvpc.id
}

ingress {
    description = "Allow port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = ["0.0.0.0/0"]
}

ingress {
    description = "Allow port 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = ["0.0.0.0/0"]
}

egress {
    description = "Allow all ports"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_block = ["0.0.0.0/0"]
}

resource "aws_security_group" "my_PrivateSG" {
    vpc_id = aws_vpc.myvpc.id
}

ingress {
    description = "Allow port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = [aws_subnet.public_subnet.cidr_block]
}

egress {
    description = "Allow all ports"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_block = ["0.0.0.0/0"]
}




