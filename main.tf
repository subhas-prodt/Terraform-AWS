provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}
 
resource "aws_vpc" "terraformmain" {
    cidr_block = "${var.cidr_block}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
      Name = "My NEW VPC"
    }
} 

resource "aws_subnet" "PublicSubnet" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  cidr_block = "${var.public_cidr_block}"
  tags {
        Name = "PublicSubnet"
  }
}

resource "aws_subnet" "PrivateSubnet" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  cidr_block = "${var.private_cidr_block}"
  tags {
        Name = "PrivateSubnet"
  }
}

resource "aws_internet_gateway" "gw" {
   vpc_id = "${aws_vpc.terraformmain.id}"
    tags {
        Name = "IGW - terraform"
    }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  tags {
      Name = "Public"
  }
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}

resource "aws_route_table_association" "PublicAssociation" {
    subnet_id = "${aws_subnet.PublicSubnet.id}"
    route_table_id = "${aws_route_table.public.id}"
}

/*
resource "aws_eip" "forNat" {
    vpc      = true
}

resource "aws_nat_gateway" "NAT" {
    allocation_id = "${aws_eip.forNat.id}"
    subnet_id = "${aws_subnet.PrivateSubnet.id}"
    depends_on = ["aws_internet_gateway.gw"]
}
*/


resource "aws_security_group" "nat" {
  # name = "Database"
  tags {
        Name = "NAT_SG"
  }
  vpc_id = "${aws_vpc.terraformmain.id}"
  ingress {
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat" {

  ami = "${lookup(var.nat_ami, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicSubnet.id}"
  source_dest_check = "false"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "NAT_instance"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.terraformmain.id}"
  tags {
      Name = "Private"
  }
  route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
        # nat_gateway_id = "${module.foundation_ec2-nat-instances.id}"
  }
}

resource "aws_route_table_association" "PrivateAssociation" {
    subnet_id = "${aws_subnet.PrivateSubnet.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_security_group" "FrontEnd" {
  name = "FrontEnd"
  tags {
        Name = "FrontEnd"
  }
  description = "ONLY HTTP CONNECTION INBOUD"
  vpc_id = "${aws_vpc.terraformmain.id}"

  ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SSH_only" {
  tags {
        Name = "SSH_only"
  }
  vpc_id = "${aws_vpc.terraformmain.id}"
  ingress {
      from_port   = "22"
      to_port     = "22"
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "PublicServer" {
  #source  = "terraform-aws-modules/ec2-instance/aws"
  #version = "1.14.0"

  ami = "${lookup(var.ami, var.region)}"
  #name = "PublicServer"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicSubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.FrontEnd.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "Public_Server"
  }
}


resource "aws_instance" "Private_Server" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id = "${aws_subnet.PrivateSubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.SSH_only.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "Private_Server"
  }
}
