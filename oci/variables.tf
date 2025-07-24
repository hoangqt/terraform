variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  default     = ""
}

variable "user_ocid" {
  description = "The OCID of the user."
  default     = ""
}

variable "fingerprint" {
  description = "The fingerprint of the API key."
  default     = ""
}

variable "private_key_path" {
  description = "The path to the private key file."
  default     = ""
}

variable "region" {
  description = "The OCI region to use."
  default     = ""
}

variable "compartment_id" {
  description = "The OCID of the compartment."
  default     = ""
}

variable "shape" {
  description = "The shape of the compute instance."
  default     = "VM.Standard2.1"
}
