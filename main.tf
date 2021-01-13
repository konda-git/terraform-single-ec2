resource "aws_vpc" "test-vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Konda-Vpc"
  }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "Test-IGW"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet-1"
  }
}

resource "aws_route_table" "test-route-table" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }

  tags = {
    Name = "Test-VPC_route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.test-route-table.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_tls"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "konda-aws"
  subnet_id = "${aws_subnet.subnet-1.id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]

  tags = {
    Name = "Terraform"
  }

}
