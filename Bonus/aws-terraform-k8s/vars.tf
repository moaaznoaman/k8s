variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

# CentOS Linux 6 x86_64 --> ami-0451e9d3427711cb1
variable "AMIS-K8S-MASTER" {
  type = map(string)
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-0ff760d16d9497662"
  }
}

variable "AMIS-K8S-WORKER" {
  type = map(string)
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-0ff760d16d9497662"
  }
}

variable "ssh_user" {
  description = "SSH user name to use for remote exec connections,"
  type        = string
  default     = "centos"
}

variable "ssh_port" {
  description = "The port the EC2 Instance should listen on for SSH requests."
  type        = number
  default     = 22
//  default     = 443
}

variable "ports" {
  type = map(list(string))
  default = {
    "22" = [ "0.0.0.0/0" ]
    "80" = [ "0.0.0.0/0" ]
    "443" = [ "0.0.0.0/0" ]
  }
}

variable "protocals" {
  type = list(string)
  default = ["tcp","udp"]
}

variable "k8s_master_count" {
  default = "1"
}

variable "k8s_worker_count" {
  default = "2"
}