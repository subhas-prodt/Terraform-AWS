variable "region" {
 default = "us-east-2"
}

variable "ami" {
  type = "map"
  default = {
    us-east-1 = "ami-0f9cf087c1f27d9b1" # Virginia
    us-east-2 = "ami-0653e888ec96eab9b" # Ohio
  }
  description = "You can add all regions here"
}

variable "nat_ami" {
  type = "map"
  default = {
    us-east-1 = "ami-00a9d4a05375b2763" # Virginia
    us-east-2 = "ami-00d1f8201864cc10c" # Ohio
  }
  description = "NAT instance ami"
}

variable "key_name" {
 default = "Ohio-Key"
}

variable "access_key" {
 default = "type-access-key-here"
}

variable "secret_key" {
 default = "type-secret-key-here"
}

variable "cidr_block" {
 default = "172.28.0.0/16"
}

variable "public_cidr_block" {
 default = "172.28.0.0/24"
}

variable "private_cidr_block" {
 default = "172.28.3.0/24"
}

