# vpc
resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# subnet 1a
resource "aws_subnet" "subnet-1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1a"
  }
}

#subnet 1b
resource "aws_subnet" "subnet-1b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1b"
  }
}

# subnet 1c
resource "aws_subnet" "subnet-1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "subnet-1c"
  }
}

# key_pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDF0CtulMZBwpGFQEgxgcAerX61YFBkbSDA488+PjmdivOa/5+twxMVTD3bY1IHlO6Q+89l+crBRTgNCsWECQt9qnUuR1Gvyv/KMbiq+OP5yrLDd9ze0Vxx0QtI7YQx6P3xIe3gYSHmZ9b5/2QeVpOsG03a5UU+TrVRO/qbwSVjmToYoJvzkh4734dMMMLlrBgbnmX3FhE8w/sjYAAyzbzmNj1WqJR5UI5KfmspVi0J4D9FbhtCQ+d163dtwqsTRnFgqwj7TG96oKST0EKKmgEwAux0CY0CkRUtTXuiPTFu+Ren8nFJncDrMwDxvqNbciawuh68qY592WdBy3ba3D29AJ8KR144iDse73H6YVcCiGp9FEI1fuWn8zs6oMBJkbEOvdfwzXjUJ/oayBajCpHBfMRF4Cj2yb1qO+Mx+02Jbf8mPzLJjHPFhj2iEXyfCMtpfM2EzccztKD4a3/Wma+mFKxYi+K9dIt/BkpCvSkxjLo9g4hjD0e4HvUPl/YKRsk= 91996@Thilaq-ES02S9JG"
}

# instance1
resource "aws_instance" "instance1" {
 ami           =   "ami-0da59f1af71ea4ad2"
 instance_type = "t2.micro"
 key_name = aws_key_pair.deployer.id
 subnet_id = aws_subnet.subnet-1a.id
 vpc_security_group_ids = [aws_security_group.allow_ssh.id]

 tags = {
   Name = "instance-1a"
 }
}

#instance2
resource "aws_instance" "instance2" {
 ami           =   "ami-0da59f1af71ea4ad2"
 instance_type = "t2.micro"
 key_name = aws_key_pair.deployer.id
 subnet_id = aws_subnet.subnet-1b.id
 vpc_security_group_ids = [aws_security_group.allow_ssh.id]

 tags = {
   Name = "instance-1b"
 }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "gw"
  }
}

# route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# route table association 1
resource "aws_route_table_association" "public_route_table_association-1" {
  subnet_id = aws_subnet.subnet-1a.id
  route_table_id = aws_route_table.public_route_table.id
}

# route table association 2
resource "aws_route_table_association" "public_route_table_association-2" {
  subnet_id = aws_subnet.subnet-1b.id 
  route_table_id = aws_route_table.public_route_table.id
}

# security group
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow ssh traffic"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description      = "ssh from my system"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
