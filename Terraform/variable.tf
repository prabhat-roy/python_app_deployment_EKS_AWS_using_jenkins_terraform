variable "azs" {

}
variable "aws_vpc_cidr" {

}
variable "public_subnet_cidrs" {

}
/*
variable "private_subnet_cidrs" {

}
*/
variable "aws_region" {

}

variable "ami" {

}

variable "private_key_path" {

}

variable "jenkins_instance_type" {
  type = string
}

variable "jenkins_agent_instance_type" {
  type = string
}

variable "sonarqube_instance_type" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "worker_node_instance_type" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "capacity" {
  type = string
}

variable "disk_size" {
  type = number
}
variable "ami_type" {
  type = string
}