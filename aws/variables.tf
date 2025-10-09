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

variable "region" {
  description = ""
  type        = string
  default     = "us-east-1"
}
