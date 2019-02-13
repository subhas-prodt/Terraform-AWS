provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  alias = "east"
  region     = "us-east-1"
}
provider "aws" {
 access_key = "${var.access_key}"
 secret_key = "${var.secret_key}"
 alias = "west"
 region = "us-west-2"
}

resource "aws_instance" "first" {
  provider = "aws.east"
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  tags {
  Name = "TerraformServer1"
  }
}

resource "aws_instance" "second" {
  provider = "aws.west"
  ami           = "ami-076e276d85f524150"
  instance_type = "t2.micro"
  tags {
  Name = "TerraformServer2"
  }
}
