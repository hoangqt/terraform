# Summary

Terraform configuration to spin up an Oracle Cloud Infrastructure compute
instance with a public IP address.

## Pre-requisites

- An Oracle Cloud Infrastructure account
- Terraform installed on your local machine

```
brew install terraform
```

- OCI CLI installed and configured with your credentials

```
brew install oci-cli
oci setup config
```

- A valid SSH key pair for accessing the instance

## Setup

- Clone repo
- terraform init
- Update `variables.tf` with your values
- terraform plan
- terraform apply
