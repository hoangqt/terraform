# Summary

Terraform configuration to spin up VMs for testing.

## Setup

### Prerequisites

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

- Initialize a working directory containing `main.tf`

```bash
terraform init
```

- Preview the changes that will be applied by Terraform

```bash
terraform plan
```

- Apply the changes required to reach the desired state of the configuration

```bash
terraform apply
```
