terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.10.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu_image" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_vcn" "ubuntu_24_04_vcn" {
  compartment_id = var.compartment_id
  display_name   = "ubuntu-24-04-vcn"
  cidr_block     = "10.0.0.0/16"
}

resource "oci_core_internet_gateway" "ubuntu_24_04_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.ubuntu_24_04_vcn.id
  display_name   = "ubuntu-24-04-igw"
  enabled        = true
}

resource "oci_core_route_table" "ubuntu_24_04_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.ubuntu_24_04_vcn.id
  display_name   = "ubuntu-24-04-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ubuntu_24_04_igw.id
  }
}

resource "oci_core_security_list" "ubuntu_24_04_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.ubuntu_24_04_vcn.id
  display_name   = "ubuntu-24-04-sl"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol    = "6"         # TCP
    source      = "0.0.0.0/0" # Replace with your IP or CIDR block for security
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "ubuntu_24_04_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.ubuntu_24_04_vcn.id
  display_name      = "ubuntu-24-04-subnet"
  cidr_block        = "10.0.0.0/24"
  route_table_id    = oci_core_route_table.ubuntu_24_04_rt.id
  security_list_ids = [oci_core_security_list.ubuntu_24_04_sl.id]
}

resource "oci_core_instance" "ubuntu_24_04" {
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "ubuntu-24-04"
  shape               = var.shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.ubuntu_24_04_subnet.id
    display_name     = "ubuntu-24-04-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_image.images[0].id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 10
  }

  metadata = {
    ssh_authorized_keys = file("${path.module}/id_rsa.pub")
  }

  launch_options {
    is_pv_encryption_in_transit_enabled = true
    network_type                        = "PARAVIRTUALIZED"
  }
}
