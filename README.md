# **Terraform Azure Infrastructure Deployment**

This Terraform project automates the provisioning of an Azure cloud environment, including a virtual network, security groups, a Linux virtual machine, and associated resources.

## **Prerequisites**
Before using this Terraform configuration, ensure you have:
- **Terraform v4.1.0** installed  
- An **Azure subscription**  
- An **SSH key pair** (if using SSH authentication for the VM)  
- The **Azure CLI** installed and authenticated (`az login`)

## **Resources Created**
This Terraform script provisions the following resources in **West Europe**:

### **1. Resource Group**
- Name: `terraform-resource`

### **2. Virtual Network**
- Name: `terraform-network`
- Address space: `10.123.0.0/16`

### **3. Subnet**
- Name: `terraform_subnet`
- Address range: `10.123.1.0/24`

### **4. Network Security Group (NSG)**
- Name: `terraformsecgroup`
- Security Rule:  
  - Allows all inbound traffic (`*`) - *Modify for production use*

### **5. Public IP Address**
- Name: `terraformip`
- Type: `Static`

### **6. Network Interface**
- Name: `networkinterface`
- Associated with `terraform_subnet`
- Uses the `terraformip` public IP

### **7. Linux Virtual Machine**
- Name: `tflinuxvm`
- Type: `Standard_B1s`
- OS: Ubuntu Server 20.04 LTS  
- SSH Key Authentication (uses `~/.ssh/virtualazurekey.pub`)  
- Runs a **local-exec provisioner** to execute a PowerShell script  

## **Usage**

### **1. Initialize Terraform**
Run the following command to initialize the Terraform working directory:
```sh
terraform init
```

### **2. Preview Changes**
To see what Terraform will create, run:
```sh
terraform plan
```

### **3. Apply Changes**
To create the resources in Azure, execute:
```sh
terraform apply -auto-approve
```

### **4. Destroy Infrastructure**
If you need to delete all resources created by Terraform:
```sh
terraform destroy -auto-approve
```

## **Customization**
- **Modify the `customdata.tpl` file** to change cloud-init configurations for the VM.  
- **Adjust NSG rules** in `azurerm_network_security_rule` to restrict access.  
- **Change the VM size (`size` attribute)** if a different instance type is needed.

## **Notes**
- The **NSG rule currently allows all inbound traffic**, which is **insecure** for production. Restrict it to specific IPs or ports.
- The **SSH key file path (`~/.ssh/virtualazurekey.pub`)** should match your actual SSH key location.
- The **local-exec provisioner** uses PowerShell to run a script after VM creation.

## **License**
This project is licensed under the **MIT License**.
