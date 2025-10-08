variable "ssh_location" {
  description = ""
  type        = string
  default     = "FIXME"
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

variable "region" {
  description = ""
  type        = string
  default     = "us-east-1"
}
