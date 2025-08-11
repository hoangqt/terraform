# Summary

Terraform configuration to spin up an Oracle Cloud Infrastructure compute
instance with a public IP address.

## Pre-requisites

- An Oracle Cloud Infrastructure account
- OCI CLI installed and configured with your credentials

```bash
brew install oci-cli
oci setup config
```

- A valid SSH key pair for accessing the instance

## Setup

- Clone repo
- Ensure `variables.tf` is configured with your OCI details
- Run terraform commands

### Connecting to the instance

Once the instance is up, you can connect to it using SSH:

```bash
ssh ubuntu@<public_ip_address>
```
