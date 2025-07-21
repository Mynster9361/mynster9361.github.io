---
title: Terraform Modules Deep Dive for PowerShell Developers - Part 6
author: mynster
date: 2025-07-11 10:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, modules, infrastructure as code, iac, azure]
description: Master Terraform modules from a PowerShell perspective - learn best practices for creating, structuring, and maintaining reusable infrastructure components.
---

> **📚 Series Navigation:**
> - [Part 1: Getting Started with Terraform for PowerShell People](/posts/GettingStartedWithTerraformForPowerShellPeople/)
> - [Part 2: Resources, Variables, and State in Terraform](/posts/ResourcesVariablesAndStateInTerraform/)
> - [Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)
> - [Part 4: Advanced State Management and Collaboration](/posts/AdvancedStateManagementAndCollaboration/)
> - [Part 5: Testing Terraform Code](/posts/TestingTerraformCode/)
> - **Part 6: Terraform Modules Deep Dive** ← *You are here*
> - Part 7: CI/CD with GitHub Actions *(August 26)*

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
├── versions.tf       # Required providers and versions
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
New-Item -ItemType Directory -Path ".\modules\webapp" -Force
New-Item -ItemType File -Path ".\modules\webapp\main.tf"
New-Item -ItemType File -Path ".\modules\webapp\variables.tf"
New-Item -ItemType File -Path ".\modules\webapp\outputs.tf"
New-Item -ItemType File -Path ".\modules\webapp\versions.tf"
```

### Module Files

```hcl
# modules/webapp/variables.tf
variable "name" {
  description = "Name of the web application"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "app_service_plan_tier" {
  description = "Tier for App Service Plan"
  type        = string
  default     = "Basic"
}

variable "app_service_plan_size" {
  description = "Size for App Service Plan"
  type        = string
  default     = "B1"
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default     = {}
}
```

```hcl
# modules/webapp/main.tf
resource "azurerm_app_service_plan" "plan" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_app_service" "app" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  
  site_config {
    dotnet_framework_version = "v5.0"
    min_tls_version          = "1.2"
    ftps_state               = "Disabled"
  }
  
  app_settings = var.app_settings
}
```

```hcl
# modules/webapp/outputs.tf
output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_app_service.app.name
}

output "app_service_default_hostname" {
  description = "The default hostname of the App Service"
  value       = azurerm_app_service.app.default_site_hostname
}

output "app_service_id" {
  description = "The ID of the App Service"
  value       = azurerm_app_service.app.id
}
```

```hcl
# modules/webapp/versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
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

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

module "web_app" {
  source              = "./modules/webapp"
  name                = "my-web-app"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "~14"
    "ENVIRONMENT"                  = "production"
  }
}

output "website_url" {
  value = "https://${module.web_app.app_service_default_hostname}"
}
```

## Module Design Patterns

### Input Variables (Like PowerShell Parameters)

In PowerShell functions, we use parameters with validation:

```powershell
function New-WebApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("westus", "eastus", "northeurope")]
        [string]$Location,
        
        [ValidateSet("Basic", "Standard", "Premium")]
        [string]$Tier = "Basic"
    )
    
    # Function logic here
}
```

In Terraform, we use input variables with validation:

```hcl
variable "name" {
  description = "Name of the web application"
  type        = string
  
  validation {
    condition     = length(var.name) > 3 && length(var.name) <= 24
    error_message = "Web app name must be between 4 and 24 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  
  validation {
    condition     = contains(["westus", "eastus", "northeurope"], var.location)
    error_message = "Allowed values are: westus, eastus, northeurope."
  }
}

variable "tier" {
  description = "Tier for App Service Plan"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.tier)
    error_message = "Allowed values are: Basic, Standard, Premium."
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
module "web_infrastructure" {
  source = "./modules/web_infrastructure"
  name   = "myapp"
  location = "westus"
}
```

Where the web_infrastructure module might look like:

```hcl
# modules/web_infrastructure/main.tf
resource "azurerm_resource_group" "this" {
  name     = "${var.name}-rg"
  location = var.location
}

module "storage" {
  source              = "../storage"
  name                = "${var.name}store"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

module "webapp" {
  source              = "../webapp"
  name                = var.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

output "resource_group" {
  value = azurerm_resource_group.this
}

output "storage" {
  value = module.storage
}

output "webapp" {
  value = module.webapp
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
├── versions.tf         # Provider requirements
├── examples/           # Example usage
│   └── basic/
│       └── main.tf
└── test/               # Tests
    └── module_test.go
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

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
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
module "webapp" {
  source  = "git::https://github.com/myorg/terraform-modules.git//modules/webapp?ref=v1.2.0"
  name    = "example"
  # ...
}
```

Or use the Terraform Registry:

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
│   ├── webapp/
│   │   ├── main.tf
│   │   ├── variables.tf
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
module "webapp" {
  source = "git::https://github.com/myorg/terraform-modules.git//modules/webapp?ref=v1.0.0"
  # ...
}
```

### Module Registry with PowerShell Integration

Create a PowerShell function to help deploy modules:

```powershell
function Get-TerraformModuleLatestVersion {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        
        [string]$RepositoryUrl = "https://github.com/myorg/terraform-modules.git"
    )
    
    # Get the latest tag from git
    $latestTag = git ls-remote --tags $RepositoryUrl | 
                 Select-String -Pattern "refs/tags/v" | 
                 ForEach-Object { $_.ToString().Split('/')[-1] } |
                 Sort-Object -Descending |
                 Select-Object -First 1
    
    if (-not $latestTag) {
        throw "No version tag found for module"
    }
    
    return @{
        Module = $ModuleName
        Version = $latestTag
        Source = "git::$RepositoryUrl//modules/$ModuleName`?ref=$latestTag"
    }
}

function New-TerraformModuleFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Variables,
        
        [string]$OutputPath = ".\main.tf"
    )
    
    $moduleInfo = Get-TerraformModuleLatestVersion -ModuleName $ModuleName
    
    $moduleContent = @"
module "$ModuleName" {
  source  = "$($moduleInfo.Source)"

"@

    foreach ($key in $Variables.Keys) {
        $value = $Variables[$key]
        if ($value -is [string]) {
            $moduleContent += "  $key = `"$value`"`n"
        } else {
            $moduleContent += "  $key = $value`n"
        }
    }
    
    $moduleContent += "}`n"
    
    Add-Content -Path $OutputPath -Value $moduleContent
    Write-Host "Added module '$ModuleName' version $($moduleInfo.Version) to $OutputPath"
}

# Example usage
New-TerraformModuleFile -ModuleName "webapp" -Variables @{
    name = "my-web-app"
    location = "westus"
    resource_group_name = "azurerm_resource_group.example.name"
}
```

## Module Testing Integration

As covered in [Part 5](/posts/TestingTerraformCode/), testing is crucial for reliable modules. Here's how to integrate testing into your module development workflow:

### Testing Module Structure

```
modules/webapp/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
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
# modules/webapp/tests/unit.tftest.hcl

# Mock provider for fast unit testing
override_provider "azurerm" {
  features {}
}

override_resource {
  target = azurerm_resource_group.test
  values = {
    name     = "test-rg"
    location = "East US"
    id       = "/subscriptions/test/resourceGroups/test-rg"
  }
}

variables {
  name                = "test-webapp"
  resource_group_name = "test-rg"
  location           = "East US"
}

run "test_app_service_plan_creation" {
  command = plan

  assert {
    condition     = azurerm_app_service_plan.plan.name == "test-webapp-plan"
    error_message = "App Service Plan name should follow naming convention"
  }

  assert {
    condition     = azurerm_app_service_plan.plan.sku[0].tier == "Basic"
    error_message = "Default tier should be Basic"
  }
}

run "test_app_service_creation" {
  command = plan

  assert {
    condition     = azurerm_app_service.app.name == "test-webapp"
    error_message = "App Service name should match input variable"
  }

  assert {
    condition     = azurerm_app_service.app.site_config[0].min_tls_version == "1.2"
    error_message = "Minimum TLS version should be 1.2 for security"
  }
}

run "test_output_values" {
  command = plan

  assert {
    condition     = output.app_service_name == "test-webapp"
    error_message = "Output should match app service name"
  }

  assert {
    condition     = can(regex("^test-webapp\\.azurewebsites\\.net$", output.app_service_default_hostname))
    error_message = "Hostname should follow Azure App Service pattern"
  }
}
```

### Integration Tests for Modules

```hcl
# modules/webapp/tests/integration.tftest.hcl

variables {
  name                     = "integration-test-webapp"
  resource_group_name      = "integration-test-rg"
  location                = "East US"
  app_service_plan_tier   = "Standard"
  app_service_plan_size   = "S1"
  app_settings = {
    "ENVIRONMENT" = "Integration"
    "VERSION"     = "1.0.0"
  }
}

# Create test resource group
run "setup_infrastructure" {
  command = apply

  module {
    source = "../examples/basic"
  }
}

run "test_webapp_deployment" {
  command = apply

  assert {
    condition     = azurerm_app_service.app.state == "Running"
    error_message = "App Service should be in Running state"
  }

  assert {
    condition     = length(azurerm_app_service.app.app_settings) >= 2
    error_message = "App settings should include custom and default values"
  }
}

run "test_security_configuration" {
  command = plan

  assert {
    condition     = azurerm_app_service.app.https_only == true
    error_message = "HTTPS should be enforced"
  }

  assert {
    condition     = azurerm_app_service.app.site_config[0].ftps_state == "Disabled"
    error_message = "FTPS should be disabled for security"
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
        
        Write-Host "✓ All tests passed for module: $ModulePath" -ForegroundColor Green
        
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
        [string]$TestType = "unit"
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

## Advanced Module Patterns

### Module Factories (Dynamic Module Creation)

Sometimes you need to create modules programmatically based on configuration. Here's a PowerShell approach:

```powershell
function New-TerraformModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        
        [Parameter(Mandatory)]
        [string]$ModuleType,
        
        [string]$OutputPath = "./modules",
        
        [hashtable]$CustomVariables = @{},
        [hashtable]$CustomResources = @{}
    )
    
    $modulePath = Join-Path $OutputPath $ModuleName
    New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
    
    # Generate variables.tf based on module type
    $variablesContent = switch ($ModuleType) {
        "webapp" {
            Get-WebAppModuleVariables -CustomVariables $CustomVariables
        }
        "database" {
            Get-DatabaseModuleVariables -CustomVariables $CustomVariables
        }
        "network" {
            Get-NetworkModuleVariables -CustomVariables $CustomVariables
        }
        default {
            throw "Unknown module type: $ModuleType"
        }
    }
    
    Set-Content -Path (Join-Path $modulePath "variables.tf") -Value $variablesContent
    
    # Generate main.tf
    $mainContent = switch ($ModuleType) {
        "webapp" {
            Get-WebAppModuleMain -CustomResources $CustomResources
        }
        "database" {
            Get-DatabaseModuleMain -CustomResources $CustomResources
        }
        "network" {
            Get-NetworkModuleMain -CustomResources $CustomResources
        }
    }
    
    Set-Content -Path (Join-Path $modulePath "main.tf") -Value $mainContent
    
    # Generate outputs.tf
    $outputsContent = Get-ModuleOutputs -ModuleType $ModuleType
    Set-Content -Path (Join-Path $modulePath "outputs.tf") -Value $outputsContent
    
    # Generate versions.tf
    $versionsContent = @"
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
  }
  required_version = ">= 1.6.0"
}
"@
    Set-Content -Path (Join-Path $modulePath "versions.tf") -Value $versionsContent
    
    # Generate basic test file
    $testContent = Get-BasicTestTemplate -ModuleName $ModuleName -ModuleType $ModuleType
    New-Item -ItemType Directory -Path (Join-Path $modulePath "tests") -Force | Out-Null
    Set-Content -Path (Join-Path $modulePath "tests/unit.tftest.hcl") -Value $testContent
    
    # Generate README
    $readmeContent = Get-ModuleReadme -ModuleName $ModuleName -ModuleType $ModuleType
    Set-Content -Path (Join-Path $modulePath "README.md") -Value $readmeContent
    
    Write-Host "✓ Generated Terraform module '$ModuleName' of type '$ModuleType' at $modulePath" -ForegroundColor Green
    return $modulePath
}

function Get-WebAppModuleVariables {
    param([hashtable]$CustomVariables)
    
    $standardVariables = @"
variable "name" {
  description = "Name of the web application"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "app_service_plan_sku" {
  description = "SKU for the App Service Plan"
  type = object({
    tier = string
    size = string
  })
  default = {
    tier = "Basic"
    size = "B1"
  }
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
"@

    # Add custom variables
    foreach ($var in $CustomVariables.GetEnumerator()) {
        $standardVariables += "`n`nvariable `"$($var.Key)`" {`n"
        $standardVariables += "  description = `"$($var.Value.Description)`"`n"
        $standardVariables += "  type        = $($var.Value.Type)`n"
        if ($var.Value.Default) {
            $standardVariables += "  default     = $($var.Value.Default)`n"
        }
        $standardVariables += "}`n"
    }
    
    return $standardVariables
}
```

### Multi-Cloud Module Patterns

Create modules that can work across different cloud providers:

```hcl
# modules/storage/variables.tf
variable "cloud_provider" {
  description = "Cloud provider (azure, aws, gcp)"
  type        = string
  default     = "azure"
  
  validation {
    condition     = contains(["azure", "aws", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be azure, aws, or gcp."
  }
}

variable "name" {
  description = "Name of the storage resource"
  type        = string
}

variable "location" {
  description = "Location/region for the storage"
  type        = string
}

variable "storage_class" {
  description = "Storage class/tier"
  type        = string
  default     = "standard"
}
```

```hcl
# modules/storage/main.tf
# Azure Storage Account
resource "azurerm_storage_account" "this" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_class == "premium" ? "Premium" : "Standard"
  account_replication_type = var.storage_class == "premium" ? "LRS" : "GRS"
  
  tags = var.tags
}

# AWS S3 Bucket
resource "aws_s3_bucket" "this" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = var.name
  tags   = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.cloud_provider == "aws" ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# GCP Storage Bucket
resource "google_storage_bucket" "this" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name          = var.name
  location      = var.location
  storage_class = upper(var.storage_class)
  
  labels = var.tags
}
```

### Module Composition with Dependency Management

```hcl
# modules/application-stack/main.tf
# This module orchestrates multiple infrastructure components

module "network" {
  source = "../network"
  
  name     = var.application_name
  location = var.location
  
  address_space = var.network_config.address_space
  subnets      = var.network_config.subnets
  
  tags = local.common_tags
}

module "database" {
  source = "../database"
  
  name                = "${var.application_name}-db"
  resource_group_name = module.network.resource_group_name
  location           = var.location
  
  # Database is deployed to private subnet
  subnet_id = module.network.subnet_ids["database"]
  
  # Database depends on network being ready
  depends_on = [module.network]
  
  tags = local.common_tags
}

module "webapp" {
  source = "../webapp"
  
  name                = var.application_name
  resource_group_name = module.network.resource_group_name
  location           = var.location
  
  # Web app is deployed to app subnet
  subnet_id = module.network.subnet_ids["application"]
  
  # Connection string references database
  app_settings = merge(var.app_settings, {
    "ConnectionStrings__DefaultConnection" = module.database.connection_string
  })
  
  # Web app depends on both network and database
  depends_on = [module.network, module.database]
  
  tags = local.common_tags
}

module "monitoring" {
  source = "../monitoring"
  
  name                = "${var.application_name}-monitoring"
  resource_group_name = module.network.resource_group_name
  location           = var.location
  
  # Monitor the web app
  app_service_id = module.webapp.app_service_id
  database_id    = module.database.database_id
  
  # Monitoring is set up after all core components
  depends_on = [module.webapp, module.database]
  
  tags = local.common_tags
}

locals {
  common_tags = merge(var.tags, {
    Application = var.application_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
```

### Module Versioning and Lifecycle Management

```powershell
# scripts/Manage-ModuleVersions.ps1
function Update-ModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModulePath,
        
        [Parameter(Mandatory)]
        [ValidateSet("major", "minor", "patch")]
        [string]$VersionType,
        
        [string]$ChangeLog = ""
    )
    
    # Read current version from versions.tf or a VERSION file
    $versionFile = Join-Path $ModulePath "VERSION"
    if (Test-Path $versionFile) {
        $currentVersion = Get-Content $versionFile
    } else {
        $currentVersion = "0.1.0"
    }
    
    # Parse semantic version
    if ($currentVersion -match "^(\d+)\.(\d+)\.(\d+)$") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        $patch = [int]$matches[3]
    } else {
        throw "Invalid version format: $currentVersion"
    }
    
    # Increment version
    switch ($VersionType) {
        "major" { $major++; $minor = 0; $patch = 0 }
        "minor" { $minor++; $patch = 0 }
        "patch" { $patch++ }
    }
    
    $newVersion = "$major.$minor.$patch"
    
    # Update VERSION file
    Set-Content -Path $versionFile -Value $newVersion
    
    # Update CHANGELOG.md
    $changelogPath = Join-Path $ModulePath "CHANGELOG.md"
    $changelogEntry = @"
## [$newVersion] - $(Get-Date -Format "yyyy-MM-dd")

### $($VersionType.ToUpper())
- $ChangeLog

"@
    
    if (Test-Path $changelogPath) {
        $existingChangelog = Get-Content $changelogPath -Raw
        $newChangelog = $changelogEntry + "`n" + $existingChangelog
    } else {
        $newChangelog = "# Changelog`n`n" + $changelogEntry
    }
    
    Set-Content -Path $changelogPath -Value $newChangelog
    
    # Create git tag
    Push-Location $ModulePath
    try {
        git add .
        git commit -m "Release version $newVersion"
        git tag -a "v$newVersion" -m "Version $newVersion: $ChangeLog"
        
        Write-Host "✓ Module version updated to $newVersion" -ForegroundColor Green
        Write-Host "  Remember to push the tag: git push origin v$newVersion" -ForegroundColor Yellow
        
    } finally {
        Pop-Location
    }
    
    return $newVersion
}

function Test-ModuleBackwardCompatibility {
    param(
        [Parameter(Mandatory)]
        [string]$ModulePath,
        
        [Parameter(Mandatory)]
        [string]$PreviousVersion
    )
    
    # This would implement compatibility testing between versions
    # For example, ensuring that outputs haven't changed in breaking ways
    Write-Host "Testing backward compatibility from $PreviousVersion..." -ForegroundColor Cyan
    
    # Check out previous version
    Push-Location $ModulePath
    try {
        git stash
        git checkout "v$PreviousVersion"
        
        # Run tests on previous version
        terraform test tests/unit.tftest.hcl
        if ($LASTEXITCODE -ne 0) {
            throw "Previous version tests failed"
        }
        
        # Switch back to current version
        git checkout -
        git stash pop
        
        # Run compatibility tests
        terraform test tests/compatibility.tftest.hcl
        if ($LASTEXITCODE -ne 0) {
            throw "Compatibility tests failed"
        }
        
        Write-Host "✓ Backward compatibility verified" -ForegroundColor Green
        
    } finally {
        Pop-Location
    }
}
```

## Conclusion and Next Steps

In this sixth part of our PowerShell-to-Terraform series, you've mastered the art of creating enterprise-grade, reusable infrastructure modules:

**What We've Accomplished:**
1. **Module Architecture**: Structured, testable modules following PowerShell development patterns
2. **Advanced Patterns**: Factory patterns, multi-cloud modules, and complex composition strategies
3. **Testing Integration**: Comprehensive module testing using the native testing framework from Part 5
4. **Lifecycle Management**: Versioning, publishing, and maintaining modules at enterprise scale
5. **PowerShell Integration**: Helper functions and automation for module development workflows

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
- **Multi-Cloud Abstractions**: Provider-agnostic infrastructure components
- **Composition Strategies**: Building complex systems from simple, tested modules
- **Integration Testing**: End-to-end validation using real infrastructure components

**Infrastructure Maturity Progression:**
✅ Foundation → ✅ Variables & State → ✅ Advanced Integration → ✅ Enterprise Collaboration → ✅ Comprehensive Testing → ✅ Production Modules → CI/CD

**Coming Next:**
In [Part 7](/posts/TerraformCICDWithGitHubActions/), our final installment, we'll bring everything together by implementing comprehensive CI/CD pipelines that automatically test, validate, and deploy your modules and infrastructure using GitHub Actions - creating a complete end-to-end automation workflow.

*You now have the skills to build and maintain enterprise-grade infrastructure module libraries!*
