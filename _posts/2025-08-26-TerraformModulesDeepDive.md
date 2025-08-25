---
title: Terraform Modules Deep Dive for PowerShell Developers - Part 6
author: mynster
date: 2025-08-26 10:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, modules, infrastructure as code, iac, azure]
description: Master Terraform modules from a PowerShell perspective - learn best practices for creating, structuring, and maintaining reusable infrastructure components.
---

> **📚 Series Navigation:**
>
> - [Part 1: Getting Started with Terraform for PowerShell People](/posts/GettingStartedWithTerraformForPowerShellPeople/)
> - [Part 2: Resources, Variables, and State in Terraform](/posts/ResourcesVariablesAndStateInTerraform/)
> - [Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)
> - [Part 4: Advanced State Management and Collaboration](/posts/AdvancedStateManagementAndCollaboration/)
> - [Part 5: Testing Terraform Code](/posts/TestingTerraformCode/)
> - **Part 6: Terraform Modules Deep Dive** ← *You are here*
> - Part 7: CI/CD with GitHub Actions *(September 2)*

## Mastering Terraform Modules for PowerShell Users

With comprehensive testing strategies from [Part 5](/posts/TestingTerraformCode/) now mastered, it's time to focus on creating reusable, production-ready infrastructure components. In this part, we'll dive deep into Terraform modules - the equivalent of PowerShell modules for infrastructure code.

As PowerShell professionals, you already understand the power of modularity from building PowerShell modules, functions, and reusable scripts. Terraform modules serve the same purpose for infrastructure code, allowing us to create standardized, testable, and maintainable components. Now that you have testing expertise, we can build modules that are thoroughly validated and enterprise-ready.

## PowerShell Modules vs. Terraform Modules

Let's compare the module concepts:

### PowerShell Module Structure

```powershell
MyPowerShellModule/
├── MyPowerShellModule.psd1     # Module manifest
├── MyPowerShellModule.psm1     # Module implementation
├── Public/                     # Public functions
│   ├── New-AzureResource.ps1
│   └── Get-AzureResource.ps1
├── Private/                    # Private functions
│   └── helpers.ps1
└── Tests/                      # Tests for the module
    └── MyModule.Tests.ps1
```

### Terraform Module Structure

```
my-terraform-module/
├── main.tf           # Main module implementation
├── data.tf           # Data sources
├── variables.tf      # Input variables definition
├── outputs.tf        # Output values definition
├── terraform.tf       # Required providers and versions
├── README.md         # Documentation
└── examples/         # Example usage
    └── basic/
        ├── main.tf
        └── variables.tf
```

## Creating Your First Terraform Module

Let's create a reusable module for a web application:

```powershell
# Create module directory structure
New-Item -ItemType Directory -Path ".\modules\resource-group" -Force
New-Item -ItemType File -Path ".\modules\resource-group\main.tf"
New-Item -ItemType File -Path ".\modules\resource-group\variables.tf"
New-Item -ItemType File -Path ".\modules\resource-group\outputs.tf"
New-Item -ItemType File -Path ".\modules\resource-group\terraform.tf"
New-Item -ItemType File -Path ".\main.tf"
```

### Module Files

```hcl
# modules/resource-group/variables.tf
variable "name" {
  description = "Name of the web application"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

```

```hcl
# modules/resource-group/main.tf
resource "azurerm_resource_group" "rg" {
  name     = "example"
  location = "West Europe"
}
```

```hcl
# modules/resource-group/outputs.tf
output "id" {
  description = "Id of the resourcegroup"
  value       = azurerm_resource_group.rg.id
}

```

```hcl
# modules/resource-group/terraform.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
  }
  required_version = ">= 1.6.0"
}
```

### Using the Module

```hcl
# main.tf
provider "azurerm" {
  features {}
}


module "resource-group" {
  source              = "./modules/resource-group"
  name                = "rg-from-mod"
  location            = "West Europe"
}
```

## Module Design Patterns

### Input Variables (Like PowerShell Parameters)

In PowerShell functions, we use parameters with validation:

```powershell
function New-rg{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [ValidateSet("westus", "eastus", "northeurope")]
        [string]$Location
    )

    # Function logic here
}
```

In Terraform, we use input variables with validation:

```hcl
variable "name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = length(var.name) > 3 && length(var.name) <= 60
    error_message = "Resource group name must be between 4 and 60 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string

  validation {
    condition     = contains(["West US", "East US", "North Europe", "West Europe"], var.location)
    error_message = "Allowed values are: West US, East US, North Europe, West Europe"
  }
}

```

### Nested Modules (Like PowerShell Functions Calling Other Functions)

In PowerShell, we often have functions that call other functions:

```powershell
function New-WebInfrastructure {
    param (
        [string]$Name,
        [string]$Location
    )

    $resourceGroup = New-AzResourceGroup -Name "$Name-rg" -Location $Location
    $storageAccount = New-StorageAccount -Name $Name -ResourceGroup $resourceGroup.ResourceGroupName
    $webApp = New-WebApp -Name $Name -Location $Location -ResourceGroup $resourceGroup.ResourceGroupName

    return @{
        ResourceGroup = $resourceGroup
        StorageAccount = $storageAccount
        WebApp = $webApp
    }
}
```

In Terraform, we use nested modules:

```hcl
module "storage_account" {
  source = "./modules/storage_account"
  name   = "mystorage"
  location = "West Europe"
}
```

Where the storage_account module might look like:

```hcl
# modules/storage_account/main.tf
module "resource_group" {
  source              = "./modules/resource-group"
  name                = "rg-from-mod"
  location            = "West Europe"
}

module "storage" {
  source              = "../storage"
  name                = "${var.name}store"
  resource_group_name = module.resource_group.name
  location            = module.resource_group..location
}

output "resource_group" {
  value = module.resource_group
}

output "storage" {
  value = module.storage
}

```

## Module Best Practices

### 1. Consistent Structure (Like PowerShell Module Structure)

Just as PowerShell modules have a recommended structure, so do Terraform modules:

```
module-name/
├── README.md           # Documentation
├── main.tf             # Main resources
├── data.tf             # Data sources
├── variables.tf        # Input variables
├── outputs.tf          # Output values
├── terraform.tf         # Provider requirements
├── examples/           # Example usage
│   └── basic/
│       └── main.tf
└── test/               # Tests
    └── module_test.tftest
```

### 2. Use Local Values for Derived Variables (Like PowerShell Local Variables)

In PowerShell:

```powershell
function Deploy-Resources {
    param ($baseName, $env)

    $resourceGroupName = "$baseName-$env-rg"
    $storageAccountName = ($baseName + $env).ToLower() -replace "[^a-z0-9]", ""

    # Use the local variables
}
```

In Terraform:

```hcl
locals {
  resource_group_name  = "${var.base_name}-${var.environment}-rg"
  storage_account_name = lower(replace("${var.base_name}${var.environment}", "/[^a-z0-9]/", ""))
}

module "resource_group" {
  source              = "./modules/resource-group"
  name     = local.resource_group_name
  location = var.location
}

module "storage" {
  source              = "../storage"
  name                = local.storage_account_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group..location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### 3. Version Your Modules (Like PowerShell Module Versioning)

In PowerShell, we version our modules in the manifest:

```powershell
# MyModule.psd1
@{
    ModuleVersion = '1.2.0'
    # ...
}
```

In Terraform, we can use Git tags for versions and reference them:

```hcl
module "resource_group" {
  source  = "git::https://github.com/myorg/terraform-modules.git//modules/resource-group?ref=v1.2.0"
  name    = "example"
  # ...
}
```

Or use the Terraform Registry:

[Terraform Registry:.](https://registry.terraform.io/browse/modules?provider=azure){:target="_blank"}

```hcl
module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "2.6.0"
  # ...
}
```

## Creating a Module Library (Like PowerShell Gallery)

While PowerShell has the PowerShell Gallery, Terraform has module registries.

### Private Module Registry

For organizations, you can set up:

1. Azure DevOps Artifacts
2. GitHub Packages
3. Terraform Cloud Private Registry

### Setting up a Simple Git-Based Registry

Create a repository structure:

```
terraform-modules/
├── modules/
│   ├── resource-group/
│   │   ├── main.tf
│   │   └── ...
│   ├── storage/
│   │   ├── main.tf
│   │   └── ...
│   └── network/
│       ├── main.tf
│       └── ...
└── README.md
```

Reference modules in your Terraform configurations:

```hcl
module "resource_group" {
  source = "git::https://github.com/myorg/terraform-modules.git//modules/resource-group?ref=v1.0.0"
  # ...
}
```

## Module Testing Integration

As covered in [Part 5](/posts/TestingTerraformCode/), testing is crucial for reliable modules. Here's how to integrate testing into your module development workflow:

### Testing Module Structure

```
modules/resource-group/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── README.md
├── examples/
│   ├── basic/
│   │   └── main.tf
│   └── advanced/
│       └── main.tf
└── tests/
    ├── unit.tftest.hcl
    ├── integration.tftest.hcl
    └── variables.auto.tfvars
```

### Unit Tests for Modules

```hcl
# modules/storage-account/tests/unit.tftest.hcl

# Mock provider for fast unit testing
override_provider "azurerm" {
  features {}
}

# Mock the resource group that the storage account depends on
override_resource {
  target = azurerm_resource_group.main
  values = {
    name     = "test-rg"
    location = "East US"
    id       = "/subscriptions/test/resourceGroups/test-rg"
  }
}

variables {
  name                = "teststorageacct"
  resource_group_name = "test-rg"
  location           = "East US"
  account_tier       = "Standard"
  replication_type   = "LRS"
  tags = {
    Environment = "Test"
    Department  = "IT"
  }
}

run "test_storage_account_creation" {
  command = plan

  assert {
    condition     = azurerm_storage_account.main.name == var.name
    error_message = "Storage account name should match input variable"
  }

  assert {
    condition     = azurerm_storage_account.main.account_tier == var.account_tier
    error_message = "Storage account tier should match input variable"
  }

  assert {
    condition     = azurerm_storage_account.main.account_replication_type == var.replication_type
    error_message = "Storage account replication type should match input variable"
  }
}

run "test_blob_properties" {
  command = plan

  assert {
    condition     = azurerm_storage_account.main.blob_properties[0].delete_retention_policy[0].days == 7
    error_message = "Default blob retention policy should be 7 days"
  }

  assert {
    condition     = azurerm_storage_account.main.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS version should be 1.2 for security"
  }
}

run "test_output_values" {
  command = plan

  assert {
    condition     = output.storage_account_id != ""
    error_message = "Storage account ID output should not be empty"
  }

  assert {
    condition     = can(regex("^https://.*\\.blob\\.core\\.windows\\.net/$", output.primary_blob_endpoint))
    error_message = "Primary blob endpoint should follow Azure pattern"
  }
}
```

### Integration Tests for Modules

```hcl
# modules/storage-account/tests/integration.tftest.hcl

variables {
  name              = "integrationtest"
  resource_group_name = "integration-test-rg"
  location         = "East US"
  account_tier     = "Standard"
  replication_type = "GRS"  # Using geo-redundant storage for integration test
  tags = {
    Environment = "Integration"
    Project     = "Testing"
  }
  allow_blob_public_access = false
  enable_https_traffic_only = true
}

# Create test resource group first
run "setup_resource_group" {
  command = apply

  module {
    source = "../examples/prerequisites"
  }
}

run "test_storage_account_deployment" {
  command = apply

  depends_on = [run.setup_resource_group]

  assert {
    condition     = azurerm_storage_account.main.account_replication_type == var.replication_type
    error_message = "Storage account should use GRS replication as specified"
  }

  assert {
    condition     = azurerm_storage_account.main.allow_blob_public_access == false
    error_message = "Public blob access should be disabled for security"
  }
}

run "test_container_creation" {
  command = apply
  depends_on = [run.test_storage_account_deployment]

  # Test that the containers are created successfully
  assert {
    condition     = length(azurerm_storage_container.containers) >= 1
    error_message = "At least one storage container should be created"
  }

  assert {
    condition     = azurerm_storage_container.containers["data"].name == "data"
    error_message = "A container named 'data' should exist"
  }
}

run "test_network_rules" {
  command = plan

  # Test that network rules are properly configured
  assert {
    condition     = azurerm_storage_account.main.network_rules[0].default_action == "Deny"
    error_message = "Network rules should deny by default for security"
  }

  assert {
    condition     = length(azurerm_storage_account.main.network_rules[0].ip_rules) > 0
    error_message = "At least one IP rule should be configured"
  }
}
```

### PowerShell Module Testing Helpers

```powershell
# scripts/Test-TerraformModule.ps1
function Test-TerraformModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModulePath,

        [ValidateSet("unit", "integration", "all")]
        [string]$TestType = "all",

        [switch]$Verbose
    )

    Push-Location $ModulePath
    try {
        Write-Host "Testing Terraform module: $ModulePath" -ForegroundColor Cyan

        switch ($TestType) {
            "unit" {
                Write-Host "Running unit tests..." -ForegroundColor Yellow
                $result = terraform test tests/unit.tftest.hcl
                if ($LASTEXITCODE -ne 0) {
                    throw "Unit tests failed"
                }
            }
            "integration" {
                Write-Host "Running integration tests..." -ForegroundColor Yellow
                $result = terraform test tests/integration.tftest.hcl
                if ($LASTEXITCODE -ne 0) {
                    throw "Integration tests failed"
                }
            }
            "all" {
                Test-TerraformModule -ModulePath $ModulePath -TestType "unit" -Verbose:$Verbose
                Test-TerraformModule -ModulePath $ModulePath -TestType "integration" -Verbose:$Verbose
            }
        }

        Write-Host "All tests passed for module: $ModulePath" -ForegroundColor Green

    } catch {
        Write-Error "Module testing failed: $_"
        throw
    } finally {
        Pop-Location
    }
}

# Test all modules in a directory
function Test-AllTerraformModules {
    param(
        [string]$ModulesPath = "./modules",

        [ValidateSet("unit", "integration", "all")]
        [string]$TestType = "all"
    )

    $modules = Get-ChildItem -Path $ModulesPath -Directory
    $results = @()

    foreach ($module in $modules) {
        try {
            Test-TerraformModule -ModulePath $module.FullName -TestType $TestType
            $results += @{ Module = $module.Name; Status = "Passed" }
        } catch {
            $results += @{ Module = $module.Name; Status = "Failed"; Error = $_.Exception.Message }
        }
    }

    # Summary
    Write-Host "`nTest Results Summary:" -ForegroundColor Blue
    foreach ($result in $results) {
        $color = if ($result.Status -eq "Passed") { "Green" } else { "Red" }
        Write-Host "  $($result.Module): $($result.Status)" -ForegroundColor $color
        if ($result.Error) {
            Write-Host "    Error: $($result.Error)" -ForegroundColor Red
        }
    }

    $passed = ($results | Where-Object { $_.Status -eq "Passed" }).Count
    $total = $results.Count
    Write-Host "`nOverall: $passed/$total modules passed" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Red" })

    return $results
}
```

## Module Versioning and Lifecycle Management

For this i would personally use dependabot to keep watch over new version and automatically create PR's for your module repository.

I will not cover the exact process but i believe this guide from GitHub should cover most circumstances:

[Enabling dependabot for your repository.](https://docs.github.com/en/code-security/getting-started/dependabot-quickstart-guide#enabling-dependabot-for-your-repository){:target="_blank"}

## Conclusion and Next Steps

In this sixth part of our PowerShell-to-Terraform series, you've mastered creating enterprise-grade, reusable infrastructure modules:

**What We've Accomplished:**

1. **Module Architecture**: Structured, testable modules following PowerShell development patterns
2. **Testing Integration**: Comprehensive module testing using the native testing framework from Part 5
3. **Lifecycle Management**: Versioning, publishing, and maintaining modules at enterprise scale

**PowerShell Developer Advantages:**
Your PowerShell module development expertise translates perfectly to Terraform modules:

- Similar project structure and organization principles
- Familiar parameter validation and input/output patterns
- Testing approaches that build on your Pester experience
- Version management strategies that mirror PowerShell Gallery patterns

**Module Maturity Achieved:**

| **Capability**           | **PowerShell Modules** | **Terraform Modules**  | **Enterprise Benefits**           |
| ------------------------ | ---------------------- | ---------------------- | --------------------------------- |
| **Code Organization**    | Functions + Manifests  | Resources + Variables  | Reusable infrastructure patterns  |
| **Parameter Validation** | Parameter attributes   | Variable validation    | Type-safe infrastructure inputs   |
| **Testing**              | Pester                 | `.tftest.hcl` + Pester | Automated validation & regression |
| **Versioning**           | Semantic versioning    | Git tags + registries  | Controlled releases & rollbacks   |
| **Distribution**         | PowerShell Gallery     | Module registries      | Team sharing & standardization    |
| **Documentation**        | Comment-based help     | README + examples      | Self-documenting infrastructure   |

**Advanced Patterns Mastered:**

- **Module Factories**: Dynamic infrastructure generation based on configuration
- **Composition Strategies**: Building complex systems from simple, tested modules
- **Integration Testing**: End-to-end validation using real infrastructure components

**Coming Next:**
In Part 7 Terraform CICD With GitHub Actions, our final chapter, we'll bring everything together by implementing comprehensive CI/CD pipelines that automatically test, validate, and deploy your modules and infrastructure using GitHub Actions - creating a complete end-to-end automation workflow.

*You now have the skills to build and maintain enterprise-grade infrastructure module libraries Congratulations!*
