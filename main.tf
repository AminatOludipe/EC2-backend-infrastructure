resource "aws_vpc" "aminat-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = "aminat-VPC"
  }
}

# Create a subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.aminat-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.aminat-VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet2"
  }
}

# Create a route table
resource "aws_route_table" "subnet1-rt" {
  vpc_id = aws_vpc.aminat-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aminat-gw.id
  }

  tags = {
    Name = "subnet1-rt"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "aminat-gw" {
  vpc_id = aws_vpc.aminat-VPC.id

  tags = {
    Name = "aminat-gw"
  }
}

# Create security group
resource "aws_security_group" "aminat-sg" {
  name        = "aminat-sg"
  vpc_id      = aws_vpc.aminat-VPC.id

  ingress {
    description      = "LB security group"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 ingress {
    description      = "LB security group"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "LB security group"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "EC2-security group"
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "aminat-sg"
  }
}

# Create an EC2
resource "aws_instance" "aminat-EC2" {
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = "t2.micro"
  key_name               = "mykey"
  vpc_security_group_ids = [aws_security_group.aminat-sg.id]
  subnet_id              = aws_subnet.subnet1.id
  associate_public_ip_address = true

  tags = {
      Name = "aminat-EC2"
  }
}
