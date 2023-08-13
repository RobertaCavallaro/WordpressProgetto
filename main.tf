provider "aws" {
  region  = "us-east-1"
}

// Create VPC
resource "aws_vpc" "custom_vpc" { #custom_vpc nome assegnato per terraform
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "terraform vpc" #nome che appare sul aws console
  }
}

// Create Subnet 1 in AZ 1a
resource "aws_subnet" "custom_subnet_1a" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a" 
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1a" #public subnet
  }
}

// Create Subnet 2 in AZ 1b
resource "aws_subnet" "custom_subnet_1b" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"  
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet1b" #private subnet
  }
}

// Create Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "CustomIGW"
  }
}

// Create Route Table updated with the above InternetGateWay
resource "aws_route_table" "custom_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name = "Myroutetable"
  }
}

// Subnet association in Route Table
resource "aws_route_table_association" "sub1a_association" {
  subnet_id      = aws_subnet.custom_subnet_1a.id
  route_table_id = aws_route_table.custom_rt.id
}



// Launch an EC2 instance for WordPress
resource "aws_instance" "wordpress_instance" {
  depends_on = [aws_subnet.custom_subnet_1a, aws_security_group.wordpress_sg] #depends on the whole object
  ami           = "aterrmi-08a52ddb321b32a8c"
  instance_type = "t2.micro"
  key_name      = "robertakeypair" #keypair
  subnet_id     = aws_subnet.custom_subnet_1a.id  #Launch an EC2 instance for WordPress in the public subnet 
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

 
  tags = {
    Name = "WordPressInstance"
  }
}

// Create Security Group for WordPress
resource "aws_security_group" "wordpress_sg" {
  depends_on = [aws_vpc.custom_vpc]
  name        = "WordPressSecurityGroup"
  description = "Allow TLS inbound and outbound traffic for WordPress"
  vpc_id      = aws_vpc.custom_vpc.id

  // Ingress rules for HTTP and SSH #assh (port 22) I can access my ec2 instance remotely, HTTP the Client can access my WordPress site.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WordPressSecurityGroup"
  }
}

