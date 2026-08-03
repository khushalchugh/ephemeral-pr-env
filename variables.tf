variable "ec2_instance_type" {
  default = "t3.micro"
  type    = string
}

variable "ec2_root_storage_size" {
  default = 8
  type    = number
}

variable "ec2_ami_id" {
  type = string
}

variable "ec2_root_storage_type" {
  default = "gp3"
  type    = string
}

variable "ec2_subnet_id" {
  default = "subnet-013351b7652900680"
  type    = string
}

variable "vpc_id" {
  default = "vpc-07bc8056b4d9ba32c"
  type    = string
}

variable "pr_number" {
  default = "local-test"
  type = string
}