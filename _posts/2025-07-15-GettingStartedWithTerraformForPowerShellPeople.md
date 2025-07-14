---
title: Getting Started with Terraform for PowerShell People - Part 1
author: mynster
date: 2025-07-14 18:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, infrastructure as code, iac, azure]
description: Learn how Terraform works from a PowerShell person's perspective, including installation, basic concepts, and your first configuration.
---

> **📚 Series Navigation:**
> - **Part 1: Getting Started with Terraform for PowerShell People** ← *You are here*
> - Part 2: Resources, Variables, and State in Terraform *(July 22)*
> - Part 3: Advanced Terraform and PowerShell Integration *(July 29)*
> - Part 4: Advanced State Management and Collaboration *(August 5)*
> - Part 5: Testing Terraform Code *(August 12)*
> - Part 6: Terraform Modules Deep Dive *(August 19)*
> - Part 7: CI/CD with GitHub Actions *(August 26)*

## Introduction to Terraform for PowerShell Users

Welcome to the first part of our comprehensive series designed specifically for PowerShell developers transitioning to Terraform. As PowerShell professionals, we're accustomed to writing imperative code that tells a system exactly *how* to do something. Terraform introduces a different paradigm - infrastructure as code (IaC) that is *declarative*, where you define *what* you want the end state to be.

Throughout this 7-part series, we'll help you transition from PowerShell scripting to Terraform by drawing parallels between concepts you already know and the new world of declarative infrastructure management. Whether you're managing Azure resources with PowerShell cmdlets or building complex automation workflows, this series will bridge that knowledge to Terraform's approach.

## Key Concept: Imperative vs. Declarative

Let's start with a simple comparison:

**PowerShell (Imperative):**
```powershell
# Note you should login with `Connect-AzAccount` before running this script
# define variables
$rgName = "MyResourceGroup"
$location = "WestEurope"
$stName = "123dfs56fgjghjghjg" # Must be globally unique

# Create a resource group if it doesn't exist
if (-not (Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $rgName -Location $location
    Write-Output "Resource group created"
} else {
    Write-Output "Resource group already exists"
}

# Create a storage account if it doesn't exist
if (-not (Get-AzStorageAccount -ResourceGroupName $rgName -Name $stName -ErrorAction SilentlyContinue)) {
    New-AzStorageAccount -ResourceGroupName $rgName `
                          -Name $stName `
                          -Location $location `
                          -SkuName Standard_LRS
    Write-Output "Storage account created"
} else {
    Write-Output "Storage account already exists"
}
```

**Terraform (Declarative):**
```hcl
# note you will need to run `terraform init` and login with `az login` before running terraform plan/apply
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "your-subscription-id" # Replace with your Azure subscription ID
}

# Define an Azure resource group
resource "azurerm_resource_group" "example" {
  name     = "MyResourceGroup"
  location = "West Europe"
}

# Define a storage account
resource "azurerm_storage_account" "example" {
  name                     = "123dfs56asdasdqwefg"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

Notice how PowerShell requires you to check if resources exist and handle that logic, while Terraform just declares the desired state.

## Installation and Setup

Installing Terraform is straightforward. There are several methods available:

### Windows (using Chocolatey)
Chocolatey can be downloaded from here
[Chocolatey download](https://chocolatey.org/install#generic){:target="_blank"}

Once installed the easiest way to install terraform is running the following in an elevated PowerShell terminal
```powershell
# Install Chocolatey if you don't have it
choco install terraform

# Verify installation
terraform -version

# Then we also need the az cli module in order to authenticate
choco install azure-cli

# Now add it to the environment path using this command
$env:PATH += ";C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"
```

### Setting Up Your Development Environment

For the best Terraform experience, especially coming from PowerShell, I recommend setting up VS Code:

```powershell
# Install VS Code extensions for Terraform development
code --install-extension HashiCorp.terraform
code --install-extension ms-vscode.powershell

# Optional not needed
code --install-extension ms-azuretools.vscode-azureresourcegroups
```

These extensions provide:
- Syntax highlighting and IntelliSense for Terraform
- Terraform plan/apply integration
- Azure resource browsing - Optional
- PowerShell debugging support for hybrid scripts

## Provider Configuration

In PowerShell, we connect to Azure using `Connect-AzAccount`. In Terraform, we configure providers:
In Terraform while running it interactively we run `az login`

```hcl
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "your-subscription-id" # Replace with your Azure subscription ID
  # Authentication happens via Az CLI, environment variables, or other methods

}
```

## Your First Terraform Configuration

Let's create a simple Terraform project:

1. Create a new directory and a file named `main.tf`:

```powershell
New-Item -ItemType Directory -Path ".\TerraformProject"
Set-Location -Path ".\TerraformProject"
New-Item -ItemType File -Path ".\main.tf"
```

2. Add this content to `main.tf`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "" # your subscription id
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "my-first-terraform-rg"
  location = "West Europe"
  
  tags = {
    environment = "Development"
    created_by  = "Terraform"
  }
}

# Define a storage account
resource "azurerm_storage_account" "example" {
  name                     = "123dfs56fg" # needs to be globally unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

3. Initialize Terraform (downloads providers):

```powershell
terraform init
```

4. Create an execution plan:

```powershell
terraform plan
```

With this we will get this output:
```hcl
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.example will be created
  + resource "azurerm_resource_group" "example" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "my-first-terraform-rg"
      + tags     = {
          + "created_by"  = "Terraform"
          + "environment" = "Development"
        }
    }

  # azurerm_storage_account.example will be created
  + resource "azurerm_storage_account" "example" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "LRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = false
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "westeurope"
      + min_tls_version                    = "TLS1_2"
      + name                               = "123dfs5dghggdh6fg"
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = "my-first-terraform-rg"
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"

      + blob_properties (known after apply)

      + network_rules (known after apply)

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)

      + static_website (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

5. Apply the changes:

```powershell
terraform apply
```

When prompted, type `yes` to confirm.

We will see something similar to the above plan and then additionally see the following:
*Note that due to storage accounts having to be globally unique you might run into an error like:*
```hcl
azurerm_resource_group.example: Creating...
azurerm_resource_group.example: Still creating... [00m10s elapsed]
azurerm_resource_group.example: Creation complete after 12s [id=/subscriptions/***/resourceGroups/my-first-terraform-rg]
azurerm_storage_account.example: Creating...
╷
│ Error: creating Storage Account (Subscription: "***"
│ Resource Group Name: "my-first-terraform-rg"
│ Storage Account Name: "123dfs56fg"): performing Create: unexpected status 409 (409 Conflict) with error: StorageAccountAlreadyTaken: The storage account named 123dfs56fg is already taken.
│
│   with azurerm_storage_account.example,
│   on main.tf line 26, in resource "azurerm_storage_account" "example":
│   26: resource "azurerm_storage_account" "example" {
│
```
- Just change the name of the sotrage account untill something sticks

```hcl
azurerm_resource_group.example: Creating...
azurerm_resource_group.example: Still creating... [00m10s elapsed]
azurerm_resource_group.example: Creation complete after 10s [id=/subscriptions/***/resourceGroups/my-first-terraform-rg]
azurerm_storage_account.example: Creating...
azurerm_storage_account.example: Still creating... [00m10s elapsed]
azurerm_storage_account.example: Still creating... [00m20s elapsed]
azurerm_storage_account.example: Still creating... [00m30s elapsed]
azurerm_storage_account.example: Still creating... [00m40s elapsed]
azurerm_storage_account.example: Still creating... [00m50s elapsed]
azurerm_storage_account.example: Still creating... [01m00s elapsed]
azurerm_storage_account.example: Creation complete after 1m5s [id=/subscriptions/***/resourceGroups/my-first-terraform-rg/providers/Microsoft.Storage/storageAccounts/123dfs5dghggdh6fg]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Further we will now have a new file called `terraform.tfstate`

## Understanding the State File

The `terraform.tfstate` file is one of Terraform's most critical components and represents a key difference from PowerShell scripting. Let's explore what it is and why it matters:

### What is the State File?

In PowerShell automation, we typically don't have a persistent record of what resources we've created - we either query the system each time or maintain our own tracking mechanism. Terraform, however, uses a state file to track everything it manages.

Think of the state file as Terraform's "database" - it contains a complete mapping between your Terraform configuration and the real-world resources it created.

### What's Inside the State File?

The state file contains:

1. **Resource mappings**: Connections between resource names in your code and their real IDs in Azure/AWS/etc.
2. **Attribute values**: All properties of your resources, including those generated by the provider
3. **Metadata**: Information about the Terraform version, provider versions, and dependencies
4. **Sensitive data**: Access keys, connection strings, and other secrets (which is why security is important)

### Why State Files Matter (PowerShell vs. Terraform)

| PowerShell Approach                    | Terraform Approach                          |
| -------------------------------------- | ------------------------------------------- |
| Query resources each run               | Read state file first                       |
| Manual tracking of dependencies        | Automatic dependency resolution             |
| Write your own logic to detect changes | Automatic diff between state and config     |
| You handle secrets separately          | Secrets stored in state file (use caution!) |

### Security Considerations

> **Security Note:** The state file contains sensitive information like access keys and connection strings. Never commit state files to version control. For production environments, use remote state with appropriate access controls.

```powershell
# Never do this with state files
git add terraform.tfstate  # BAD: Contains secrets

# Instead, add to .gitignore
echo "*.tfstate" >> .gitignore
echo "*.tfstate.backup" >> .gitignore
```
## Cleanup the deployment again

To cleanup the resources we just deployed we can just run
```powershell
terraform destroy
```

When prompted, type `yes` to confirm.

Which would give you the plan again this time with red - in it to display what it is destroying and the following
```hcl
Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_storage_account.example: Destroying... [id=/subscriptions/***/resourceGroups/my-first-terraform-rg/providers/Microsoft.Storage/storageAccounts/123dfs5dghggdh6fg]
azurerm_storage_account.example: Destruction complete after 4s
azurerm_resource_group.example: Destroying... [id=/subscriptions/***/resourceGroups/my-first-terraform-rg]
azurerm_resource_group.example: Still destroying... [id=/subscriptions/***/resourceGroups/my-first-terraform-rg, 00m10s elapsed]
azurerm_resource_group.example: Destruction complete after 17s

Destroy complete! Resources: 2 destroyed.
```


## Understanding the Terraform Workflow

The Terraform workflow can be understood by comparing it to familiar PowerShell concepts:

| PowerShell                     | Terraform           | Description                         |
| ------------------------------ | ------------------- | ----------------------------------- |
| `Import-Module/Install-Module` | `terraform init`    | Prepares environment/dependencies   |
| `Get-*`, scripted checks       | `terraform plan`    | Shows what would happen (read-only) |
| `New-*`, `Set-*` cmdlets       | `terraform apply`   | Makes actual changes                |
| `Remove-*` cmdlets             | `terraform destroy` | Removes all created resources       |

## PowerShell vs. Terraform: State Management

One fundamental difference is how state is managed:

**PowerShell:**
- Stateless by default
- You query current state each time
- You write logic to handle differences

**Terraform:**
- Stores state in a state file
- Compares desired state to current state
- Automatically determines required changes
> **Security Note:** Terraform state files can contain sensitive information. Never commit them to version control. For production environments, consider using remote state with appropriate access controls.


## Conclusion and Next Steps

In this first part of our PowerShell-to-Terraform series, we've established the foundation you need to start your infrastructure automation journey. We've covered:

1. **Conceptual Bridge**: Understanding the shift from PowerShell's imperative approach to Terraform's declarative model
2. **Environment Setup**: Installation methods and VS Code configuration for optimal development experience
3. **Your First Terraform Configuration**: Created, planned, applied, and destroyed your first Terraform configuration
4. **State Awareness**: Understanding how Terraform tracks and manages infrastructure state
5. **Security Foundations**: Best practices for handling sensitive data in state files

**What We've Achieved:**
- Installed and configured Terraform with proper tooling
- Understood the fundamental workflow differences between PowerShell and Terraform
- Successfully deployed and managed Azure resources declaratively
- Established security best practices from day one

**Coming Next:**
Part 2 (releasing July 22) will build on this foundation by exploring how to make your Terraform code more flexible and reusable using variables, outputs, and data sources - concepts that will feel familiar from PowerShell parameters and return values.

**Series Progress:** ✅ Foundation → Variables & State → Integration → Collaboration → Testing → Modules → CI/CD

## Your Terraform Journey Ahead

This series is designed to take you from PowerShell scripter to Terraform expert through a carefully planned progression:

**🎯 Learning Path Overview:**
- **Parts 1-2**: Foundation and core concepts (where you are now)
- **Parts 3-4**: Integration with PowerShell and team collaboration
- **Parts 5-6**: Testing strategies and production-ready modules
- **Part 7**: Complete CI/CD automation with GitHub Actions

**💡 What Makes This Series Different:**
Unlike general Terraform tutorials, every concept is explained through PowerShell parallels, making your existing knowledge an advantage rather than something to forget. You'll learn not just *what* to do, but *why* it matters from a PowerShell professional's perspective.

**🚀 By the End, You'll Have:**
- A complete enterprise infrastructure automation platform
- Skills that combine PowerShell flexibility with Terraform's declarative power
- Practical experience with testing, modules, and CI/CD for infrastructure
- Knowledge that positions you for modern cloud infrastructure roles

## Common Gotchas for PowerShell Users

When transitioning from PowerShell to Terraform, watch out for these common issues:

### 1. String Interpolation Differences
```powershell
# PowerShell
$resourceName = "rg-$environment-$location"
```

```hcl
# Terraform - note the syntax difference
locals {
  resource_name = "rg-${var.environment}-${var.location}"
}
```

### 2. Error Handling Philosophy
```powershell
# PowerShell - explicit error handling
try {
    New-AzResourceGroup -Name $rgName -Location $location
    Write-Host "Success!"
} catch {
    Write-Error "Failed: $($_.Exception.Message)"
    # Custom remediation logic
} finally {
    Write-Host "Cleanup actions if necessary"
    # For example, removing temporary files or resetting variables
}
```

```hcl
# Terraform - declarative error handling
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
  
  # Terraform handles errors automatically
  # You define what you want, not how to handle failures
}
```

### 3. Case Sensitivity
PowerShell is generally case-insensitive, but Terraform is case-sensitive:
- Resource names: `azurerm_resource_group` (not `azurerm_Resource_Group`)
- Variable references: `var.location` (not `var.Location`)

### 4. Comments Syntax
```powershell
# PowerShell comment
<# 
PowerShell
multi-line
comment
#>
```

```hcl
# Terraform comment (only single-line supported)
/* 
Multi-line 
comments 
*/
```
