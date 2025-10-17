variable "ssh_cidrs" {
  description = ""
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your IP range for better security
}

variable "ingress_cidrs" {
  description = ""
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your IP range for better security
}

variable "egress_cidrs" {
  description = ""
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your IP range for better security
}

variable "key_name" {
  description = ""
  type        = string
  default     = "ubuntu"
}

variable "tag_name" {
  description = ""
  type        = string
  default     = "ubuntu-24-04"
}

variable "instance_type" {
  description = ""
  type        = string
  default     = "t3.micro"
}

variable "volume_size" {
  description = ""
  type        = number
  default     = 8
}

variable "volume_type" {
  description = ""
  type        = string
  default     = "gp3"
}

variable "security_group_name" {
  description = ""
  type        = string
  default     = "ubuntu-sg"
}

variable "bastion_security_group_name" {
  description = ""
  type        = string
  default     = "bastion-sg"
}

variable "region" {
  description = ""
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = ""
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = ""
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    public_a = {
      cidr = "10.0.0.0/24"
      az   = "us-east-1a"
    }
    public_b = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  description = ""
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    private_a = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    private_b = {
      cidr = "10.0.3.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "bastion_ssh_cidrs" {
  description = ""
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace with your IP range for better security
}

variable "bastion_key_name" {
  description = ""
  type        = string
  default     = "ubuntu"
}

variable "bastion_tag_name" {
  description = ""
  type        = string
  default     = "ubuntu-24-04-bastion"
}

variable "bastion_instance_type" {
  description = ""
  type        = string
  default     = "t3.micro"
}

variable "bastion_volume_size" {
  description = ""
  type        = number
  default     = 8
}
