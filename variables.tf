variable "region" {
 default = "us-east-1"
}

variable "ami" {
  type = "map"
  default = {
    us-east-1 = "ami-b73b63a0" # Virginia
    us-west-2 = "ami-5ec1673e" # Oregon
    eu-west-1 = "ami-9398d3e0" # Ireland
    us-east-2 = "ami-ea87a78f" # Ohio
  }
  description = "I add only 3 regions (Virginia, Oregon, Ireland) to show the map feature but you can add all the regions that you need"
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
