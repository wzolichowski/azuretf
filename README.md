# Terraform Azure Infrastructure

## Overview
This Terraform project provisions an Azure environment, including a resource group, virtual network, subnet, network security group, public IP, network interface, and a Linux virtual machine.

## Prerequisites
Before running this Terraform configuration, ensure you have the following:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- An active Azure subscription
- Azure CLI installed and authenticated (`az login`)
- SSH key pair for VM access (`~/.ssh/virtualazurekey.pub`)

## Resources Created
This Terraform configuration provisions the following resources:

- **Resource Group**: `terraform-resource`
- **Virtual Network**: `terraform-network` (Address space: `10.123.0.0/16`)
- **Subnet**: `terraform_subnet` (CIDR: `10.123.1.0/24`)
- **Network Security Group**: `terraformsecgroup` (Allowing inbound traffic)
- **Public IP**: `terraformip` (Static allocation)
- **Network Interface**: `networkinterface`
- **Linux Virtual Machine**: `tflinuxvm` (Ubuntu 20.04 LTS)

## Configuration
### Variables
- `subscription_id`: Your Azure Subscription ID
- `host_os`: Operating system for provisioning script execution (e.g., `linux`, `windows`)

### Custom Data (Cloud-init Script)
The `customdata.tpl` script installs essential packages such as Docker, Git, Vim, and Python.

## Usage
### 1. Initialize Terraform
Run the following command to initialize the Terraform working directory:
```sh
terraform init
```

### 2. Plan Deployment
To preview the changes Terraform will apply, run:
```sh
terraform plan
```

### 3. Apply Changes
Deploy the infrastructure using:
```sh
terraform apply -auto-approve
```

### 4. Retrieve Public IP
After provisioning, get the VM's public IP with:
```sh
terraform output public_ip_address
```

### 5. Connect to the VM
Use SSH to access the VM:
```sh
ssh -i ~/.ssh/virtualazurekey azureuser@<public-ip>
```

## Cleanup
To remove all resources, run:
```sh
terraform destroy -auto-approve
```

## Notes
- Ensure SSH keys exist at `~/.ssh/virtualazurekey` before applying.
- Modify the `customdata.tpl` script to customize package installations.
- This configuration uses a `local-exec` provisioner to run OS-specific scripts based on `host_os`.
- Customize your path to .ssh if you are using Windows.


