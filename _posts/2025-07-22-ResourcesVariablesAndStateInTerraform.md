---
title: Getting Started with Terraform for PowerShell People - Part 2
author: mynster
date: 2025-07-22 06:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, infrastructure as code, iac, azure, variables]
description: Learn about Terraform resources, variables, and state management from a PowerShell perspective, with practical examples.
---

> **📚 Series Navigation:**
>
> - [Part 1: Getting Started with Terraform for PowerShell People](/posts/GettingStartedWithTerraformForPowerShellPeople/)
> - **Part 2: Resources, Variables, and State in Terraform** ← *You are here*
> - [Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)
> - [Part 4: Advanced State Management and Collaboration](/posts/AdvancedStateManagementAndCollaboration/)
> - [Part 5: Testing Terraform Code](/posts/TestingTerraformCode/)
> - [Part 6: Terraform Modules Deep Dive](/posts/TerraformModulesDeepDive/)
> - Part 7: CI/CD with GitHub Actions *(September 9)*

## Building Flexible Infrastructure with PowerShell Parallels

Now that you've got your [Terraform foundation in place](/posts/GettingStartedWithTerraformForPowerShellPeople/) and successfully deployed your first resources, it's time to make your infrastructure code more flexible and maintainable. In this part, we'll explore concepts that will feel familiar from PowerShell development: making code reusable with parameters (variables), returning useful information (outputs), and querying existing resources (data sources).

As PowerShell developers, you already understand the power of parameterized scripts and functions. Terraform variables work similarly but with additional features like type validation and complex data structures that enable robust infrastructure definitions.

## Terraform Resources in Depth

In PowerShell, we use cmdlets like `New-AzVM` or `New-AzStorageAccount` to create resources. In Terraform, we use resource blocks:

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
  subscription_id = "your-subscription-id" # Replace with your Azure subscription ID
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

Notice how resources can reference each other - similar to storing outputs in PowerShell variables and using them as inputs to other cmdlets.

### Resource Dependencies

In PowerShell, we manage dependencies explicitly with ordered commands:

```powershell
# PowerShell - explicit ordering
$rg = New-AzResourceGroup -Name "example" -Location "WestEurope"
$vnet = New-AzVirtualNetwork -ResourceGroupName $rg.ResourceGroupName -Name "example-vnet" -Location $rg.Location -AddressPrefix "10.0.0.0/16"
```

In Terraform, dependencies are automatically detected through references:

```hcl
# Terraform - implicit dependency through reference
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  # This creates an implicit dependency
}
```

You can also create explicit dependencies which can be handy when some resources take a long time to create and be in place:

```hcl
resource "azurerm_subnet" "example" {
  # Properties...

  depends_on = [
    azurerm_virtual_network.example
  ]
}
```

## Variables and Outputs

### Variables in Terraform (Like PowerShell Parameters)

In PowerShell, we use parameters to make scripts flexible:

```powershell
param(
    [string]$ResourceGroupName = "default-rg",
    [string]$Location = "Westeurope",
    [string]$Environment = "dev"
)
```

In Terraform, we use input variables:

```hcl
# variables.tf
variable "resource_group_name" {
  type        = string
  default     = "default-rg"
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Azure region to deploy resources"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment (dev, test, prod)"
}
```

Using variables in your main configuration:

```hcl
# main.tf
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


resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
```

### Outputs (Like PowerShell Return Values)

In PowerShell, we return values from functions:

```powershell
function Create-ResourceGroup {
    param($name, $location)
    $rg = New-AzResourceGroup -Name $name -Location $location
    return $rg
}

$result = Create-ResourceGroup -name "example" -location "Westeurope"
Write-Host $result.ResourceId
```

In Terraform, we use output values:

```hcl
# outputs.tf
output "resource_group_id" {
  value       = azurerm_resource_group.example.id
  description = "The ID of the resource group"
}

output "vnet_address_space" {
  value       = azurerm_virtual_network.example.address_space
  description = "The address space of the VNet"
}
```

After running `terraform apply`, the output will be printed like so:

```hcl
azurerm_resource_group.example: Creating...
azurerm_resource_group.example: Still creating... [00m10s elapsed]
azurerm_resource_group.example: Creation complete after 12s [id=/subscriptions/***/resourceGroups/default-rg-dev]
azurerm_virtual_network.example: Creating...
azurerm_virtual_network.example: Creation complete after 8s [id=/subscriptions/***/resourceGroups/default-rg-dev/providers/Microsoft.Network/virtualNetworks/example-network]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

resource_group_id = "/subscriptions/***/resourceGroups/default-rg-dev"
vnet_address_space = toset([
  "10.0.0.0/16",
])
```

you can see outputs with:

```powershell
terraform output
<#
resource_group_id = "/subscriptions/***/resourceGroups/default-rg-dev"
vnet_address_space = toset([
  "10.0.0.0/16",
])
#>
# or for a specific output
terraform output resource_group_id
# "/subscriptions/***/resourceGroups/default-rg-dev"
```

## Understanding Terraform State in Depth

One major difference from PowerShell is that Terraform keeps track of what it has created in a state file. This is crucial for understanding how Terraform works.

### State File Contents and PowerShell Comparison

In PowerShell, if you want to track deployment state, you might create something like this:

```powershell
# PowerShell manual state tracking
$deploymentState = @{
    Timestamp = Get-Date
    ResourceGroupName = "test-rg"
    Location = "West Europe"
    StorageAccountName = "teststorageagjhkunt123" # Must be globally unique
    Resources = @()
    Outputs = @{}
}

$resourceGroup = New-AzResourceGroup -Name $deploymentState.ResourceGroupName -Location $deploymentState.Location
$deploymentState.Resources += @{
    Type = "ResourceGroup"
    Name = $deploymentState.ResourceGroupName
    Id = $resourceGroup.Id
    Properties = $resourceGroup
}

# After creating each resource
$storageAccount = New-AzStorageAccount -ResourceGroupName $deploymentState.ResourceGroupName -Name $deploymentState.StorageAccountName -Location $deploymentState.Location -SkuName Standard_LRS
$deploymentState.Resources += @{
    Type = "StorageAccount"
    Name = $storageAccount.StorageAccountName
    Id = $storageAccount.Id
    Properties = $storageAccount
}

# Save state
$deploymentState | ConvertTo-Json -Depth 10 | Set-Content -Path ".\deployment-state.json"
```

And then you will end up with a long json file like this example *truncated*

```json
{
  "Resources": [
    {
      "Id": null,
      "Type": "ResourceGroup",
      "Name": "test-rg",
      "Properties": {
        "ResourceGroupName": "test-rg",
        "Location": "westeurope",
        "ProvisioningState": "Succeeded",
        "Tags": null,
        "TagsTable": null,
        "ResourceId": "/subscriptions/***/resourceGroups/test-rg",
        "ManagedBy": null
      }
    },
    {
      "Id": "/subscriptions/***/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorageagjhkunt123",
      "Type": "StorageAccount",
      "Name": "teststorageagjhkunt123",
      "Properties": {"Removed due to length": true}
    }
  ],
  "Timestamp": "2025-07-13T13:44:42.577466+02:00",
  "Location": "West Europe",
  "ResourceGroupName": "test-rg",
  "Outputs": {},
  "StorageAccountName": "teststorageagjhkunt123"
}
```

Terraform handles this automatically and stores much more detailed information:

```json
{
  "version": 4,
  "terraform_version": "1.8.5",
  "resources": [
    {
      "mode": "managed",
      "type": "azurerm_storage_account",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
      "instances": [
        {
          "attributes": {
            "id": "/subscriptions/.../storageAccounts/mystorageaccount",
            "name": "mystorageaccount",
            "primary_access_key": "sensitive_key_here",
            // ... hundreds of other attributes
          }
        }
      ]
    }
  ]
}
```

### Remote State Configuration

By default, Terraform uses a local `terraform.tfstate` file, but in team environments, you'll want to use remote state:

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestorage"
    container_name       = "tfstate"
    key                  = "project1.tfstate"
  }
}
```

### Setting Up Remote State with PowerShell

Here's a PowerShell script to set up the remote state infrastructure:

```powershell
# setup-remote-state.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName = "terraform-state-rg",

    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,

    [string]$Location = "East US",
    [string]$ContainerName = "tfstate"
)

# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# Create resource group for state storage
$rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force
Write-Host "Created resource group: $($rg.ResourceGroupName)" -ForegroundColor Green

# Create storage account
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -Name $StorageAccountName `
    -Location $Location `
    -SkuName "Standard_LRS" `
    -Kind "StorageV2" `
    -EnableHttpsTrafficOnly $true

Write-Host "Created storage account: $($storageAccount.StorageAccountName)" -ForegroundColor Green

# Create container
$ctx = $storageAccount.Context
$container = New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Off
Write-Host "Created container: $($container.Name)" -ForegroundColor Green

# Output backend configuration
Write-Host "`nAdd this to your backend.tf file:" -ForegroundColor Yellow
Write-Host @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$ResourceGroupName"
    storage_account_name = "$StorageAccountName"
    container_name       = "$ContainerName"
    key                  = "terraform.tfstate"
  }
}
"@ -ForegroundColor Cyan
```

### Working with State Commands

Terraform provides several commands for managing state that are useful for troubleshooting:

```powershell
# List all resources in the state (like Get-ChildItem for infrastructure)
terraform state list

# Show detailed information about a specific resource (like Get-AzResource with details)
terraform state show 'azurerm_resource_group.example'

# Remove a resource from state without destroying it (like unregistering without deletion)
terraform state rm 'azurerm_resource_group.example'

# Move a resource in state (useful for refactoring)
terraform state mv 'azurerm_resource_group.old_name' 'azurerm_resource_group.new_name'

# Pull remote state to local file for inspection
terraform state pull > current-state.json

# Push local state to remote (use with caution!)
terraform state push terraform.tfstate
```

### State Inspection with PowerShell

You can also inspect Terraform state using PowerShell:

```powershell
# Read and analyze Terraform state
$state = terraform output -json | ConvertFrom-Json

# Get all resource IDs
$resourceIds = terraform state list

# Show resource details
foreach ($resourceId in $resourceIds) {
    Write-Host "Resource: $resourceId" -ForegroundColor Green
    terraform state show $resourceId
    Write-Host "---" -ForegroundColor Gray
}

# Export state summary
$stateSummary = @{
    Timestamp = Get-Date
    Resources = @()
}

foreach ($resourceId in $resourceIds) {
    $resourceInfo = terraform state show $resourceId -json | ConvertFrom-Json
    $stateSummary.Resources += @{
        Id = $resourceId
        Type = $resourceInfo.type
        Name = $resourceInfo.name
    }
}

$stateSummary | ConvertTo-Json | Set-Content -Path "state-summary.json"
```

## Data Sources: The Terraform Equivalent of Get-* Cmdlets

In PowerShell, we frequently use `Get-*` cmdlets to retrieve information about existing resources:

```powershell
# PowerShell - querying existing resources
$existingRG = Get-AzResourceGroup -Name "shared-resources"
$existingVNet = Get-AzVirtualNetwork -Name "shared-vnet" -ResourceGroupName $existingRG.ResourceGroupName

# Use the existing resources in our script
$subnet = New-AzVirtualNetworkSubnetConfig -Name "app-subnet" -AddressPrefix "10.0.1.0/24"
$existingVNet | Add-AzVirtualNetworkSubnetConfig -Subnet $subnet
```

In Terraform, we use data sources to query existing infrastructure:

```hcl
# Terraform - data sources to query existing resources
data "azurerm_resource_group" "shared" {
  name = "shared-resources"
}

data "azurerm_virtual_network" "shared" {
  name                = "shared-vnet"
  resource_group_name = data.azurerm_resource_group.shared.name
}

# Use the existing resources in our configuration
resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = data.azurerm_resource_group.shared.name
  virtual_network_name = data.azurerm_virtual_network.shared.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

### Common Data Source Patterns

Here are some frequently used data sources that PowerShell users will find familiar:

```hcl
# Get current Azure client configuration (like Get-AzContext)
data "azurerm_client_config" "current" {}

# Get information about an existing Key Vault (like Get-AzKeyVault)
data "azurerm_key_vault" "shared" {
  name                = "shared-keyvault"
  resource_group_name = "shared-resources"
}

# Get a Key Vault secret (like Get-AzKeyVaultSecret)
data "azurerm_key_vault_secret" "database_password" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.shared.id
}

# Use the secret in a resource
resource "azurerm_mssql_server" "example" {
  name                         = "example-sqlserver"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  administrator_login          = "sqladmin"
  administrator_login_password = data.azurerm_key_vault_secret.database_password.value
}
```

## Practical Example: Web App with Variables

Here's a complete example deploying an Azure Web App with reusable variables:

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
  subscription_id = "your-subscription-id" # Replace with your Azure subscription ID
}

# variables.tf
variable "base_name" {
  type        = string
  description = "Base name for resources"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment (dev, test, prod)"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Azure region"
}

# main.tf
resource "azurerm_resource_group" "example" {
  name     = "${var.base_name}-${var.environment}-rg"
  location = var.location
}

resource "azurerm_service_plan" "example" {
  name                = "${var.base_name}-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  os_type  = "Linux"
  sku_name = "P1v2"
}

resource "azurerm_linux_web_app" "example" {
  name                = "examplemortenkr"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

# outputs.tf
output "website_url" {
  value = "https://${azurerm_linux_web_app.example.default_hostname}"
}
```

Running this example:

```powershell
terraform init
terraform plan -var "base_name=mywebapp" -var "environment=dev"
terraform apply -var "base_name=mywebapp" -var "environment=dev"
```

## Advanced Variable Types and Validation

PowerShell has rich parameter validation otherwise refered to as a ValidateSet which is just a set of options that can be chosen for a given parameter. Terraform provides similar capabilities:

**PowerShell Parameter Validation:**

```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment,

    [Parameter(Mandatory=$true)]
    [ValidateRange(1, 100)]
    [int]$InstanceCount,

    [ValidatePattern("^[a-z0-9-]+$")]
    [string]$ResourceName
)
```

**Terraform Variable Validation:**

```hcl
variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 100
    error_message = "Instance count must be between 1 and 100."
  }
}

variable "resource_name" {
  type        = string
  description = "Name for the resource"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_name))
    error_message = "Resource name must contain only lowercase letters, numbers, and hyphens."
  }
}
```

### Complex Variable Types

Terraform supports complex data types similar to PowerShell objects and hashtables:

**PowerShell Objects and Hashtables:**

```powershell
# PowerShell hashtable
$appSettings = @{
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "ConnectionStrings__DefaultConnection" = $connectionString
}

# PowerShell custom object
$vmConfig = [PSCustomObject]@{
    Name = "web-vm-01"
    Size = "Standard_B2s"
    Os = "Ubuntu"
}
```

**Terraform Object and Map Types:**

```hcl
# Terraform map variable (like PowerShell hashtable)
variable "app_settings" {
  type = map(string)
  default = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "WEBSITE_TIME_ZONE"      = "UTC"
  }
}

# Terraform object variable (like PowerShell custom object)
variable "vm_config" {
  type = object({
    name = string
    size = string
    os   = string
  })
  default = {
    name = "web-vm-01"
    size = "Standard_B2s"
    os   = "Ubuntu"
  }
}

# List of objects (like PowerShell array of objects)
variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = [
    {
      name           = "frontend"
      address_prefix = "10.0.1.0/24"
    },
    {
      name           = "backend"
      address_prefix = "10.0.2.0/24"
    }
  ]
}
```

### Using Complex Variables

```hcl
# Using the complex variables in resources
resource "azurerm_linux_web_app" "example" {
  name                = var.vm_config.name
  # ...other configuration...

  app_settings = var.app_settings
}

resource "azurerm_subnet" "example" {
  count = length(var.subnets)

  name                 = var.subnets[count.index].name
  address_prefixes     = [var.subnets[count.index].address_prefix]
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
}
```

## Local Values: Terraform's Equivalent to PowerShell Local Variables

In PowerShell functions, we often compute values locally:

```powershell
function Deploy-WebApp {
    param($BaseName, $Environment, $Location)

    # Local computed values
    $resourceGroupName = "$BaseName-$Environment-rg"
    $appServiceName = "$BaseName-$Environment-app"
    $storageAccountName = ($BaseName + $Environment).ToLower() -replace '[^a-z0-9]', ''
    $commonTags = @{
        Environment = $Environment
        Project = $BaseName
        ManagedBy = "Terraform"
        CreatedDate = (Get-Date).ToString("yyyy-MM-dd")
    }

    # Use the computed values
    New-AzResourceGroup -Name $resourceGroupName -Location $Location -Tag $commonTags
}
```

In Terraform, we use `locals` blocks for computed values:

```hcl
locals {
  # Computed naming
  resource_group_name  = "${var.base_name}-${var.environment}-rg"
  app_service_name     = "${var.base_name}-${var.environment}-app"
  storage_account_name = lower(replace("${var.base_name}${var.environment}", "/[^a-z0-9]/", ""))

  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.base_name
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  # Conditional logic.
  # The two below examples basicly says if the variable environment is set to "prod" the app_service_pla_tier is PremiumV2
  # And the same goes for backuup_retention_days if environment is set to "prod" then the retention is set to 30
  app_service_plan_tier = var.environment == "prod" ? "PremiumV2" : "Standard"
  backup_retention_days = var.environment == "prod" ? 30 : 7
}

# Use locals in resources
resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "example" {
  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  tags               = local.common_tags

  # Use conditional local
  backup_retention_policy {
    days = local.backup_retention_days
  }
}
```

### Benefits of Locals vs Direct Variable References

| Approach            | PowerShell                      | Terraform                        |
| ------------------- | ------------------------------- | -------------------------------- |
| **Direct Usage**    | `$var` directly in commands     | `var.variable_name` in resources |
| **Computed Values** | Local variables in functions    | `locals` block                   |
| **Reusability**     | Function parameters             | Variables + locals combination   |
| **DRY Principle**   | Avoid repetition with variables | Avoid repetition with locals     |

## Variable Files: Environment-Specific Configuration

In PowerShell, we often use configuration files for different environments:

```powershell
# PowerShell approach - environment-specific config files
$config = Get-Content ".\config.$Environment.json" | ConvertFrom-Json

# Or using parameter splatting
$devParams = @{
    ResourceGroupName = "myapp-dev-rg"
    AppServicePlanTier = "Basic"
    DatabaseTier = "Basic"
}

$prodParams = @{
    ResourceGroupName = "myapp-prod-rg"
    AppServicePlanTier = "Premium"
    DatabaseTier = "Standard"
}
```

Terraform uses `.tfvars` files for environment-specific values:

**dev.tfvars:**

```hcl
base_name = "myapp"
environment = "dev"
location = "West Europe"

app_service_plan_tier = "Basic"
app_service_plan_size = "B1"
database_tier = "Basic"
database_capacity = 2

enable_backup = false
enable_monitoring = false
```

**prod.tfvars:**

```hcl
base_name = "myapp"
environment = "prod"
location = "East US"

app_service_plan_tier = "PremiumV2"
app_service_plan_size = "P1v2"
database_tier = "GeneralPurpose"
database_capacity = 4

enable_backup = true
enable_monitoring = true
backup_retention_days = 30
```

**Using variable files:**

```powershell
# Deploy to dev environment
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# Deploy to prod environment
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

### PowerShell Script for Environment Management

You can create a PowerShell wrapper to manage different environments:

```powershell
# deploy.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment,

    [switch]$PlanOnly
)

$varFile = "$Environment.tfvars"

if (-not (Test-Path $varFile)) {
    Write-Error "Variable file $varFile not found!"
    exit 1
}

Write-Host "Deploying to $Environment environment..." -ForegroundColor Green

# Initialize Terraform
terraform init

if ($PlanOnly) {
    # Just show the plan
    terraform plan -var-file=$varFile
} else {
    # Apply the changes
    terraform plan -var-file=$varFile -out="$Environment.tfplan"

    $confirmation = Read-Host "Apply these changes to $Environment? (yes/no)"
    if ($confirmation -eq "yes") {
        terraform apply "$Environment.tfplan"
        Remove-Item "$Environment.tfplan" -Force
    } else {
        Write-Host "Deployment cancelled" -ForegroundColor Yellow
        Remove-Item "$Environment.tfplan" -Force
    }
}
```

## Conclusion and Next Steps

In this second part of our PowerShell-to-Terraform series, you've learned to build flexible, maintainable infrastructure code using familiar concepts adapted to Terraform's declarative approach:

**What We've Mastered:**

1. **Resource Dependencies**: Terraform's automatic dependency resolution vs PowerShell's explicit ordering
2. **Variables & Validation**: Type-safe infrastructure parameters with built-in validation rules
3. **Data Sources**: Terraform's approach to querying existing infrastructure (like PowerShell's `Get-*` cmdlets)
4. **Advanced Variable Types**: Complex objects, maps, and lists for sophisticated configurations
5. **Local Values**: Computed values and DRY principles (like local variables in PowerShell functions)
6. **Environment Management**: Using `.tfvars` files for environment-specific configurations
7. **State Deep Dive**: Understanding Terraform's comprehensive state tracking vs PowerShell's stateless operations

**PowerShell Developer Key Insights:**

- Variables in Terraform are more powerful than PowerShell parameters with runtime validation
- Data sources eliminate the need for custom `Get-*` cmdlet equivalent scripts
- Local values provide the same benefits as local variables in PowerShell functions
- Terraform state removes the need for manual resource tracking that PowerShell scripts often require

**Infrastructure Maturity Progression:**
✅ Foundation → ✅ Variables & State → Integration → Collaboration → Testing → Modules → CI/CD

**Coming Next:**
Part 3 (releasing July 29), we'll explore advanced concepts like modules (Terraform's equivalent to PowerShell modules), loops and conditionals, and how to integrate Terraform with your existing PowerShell automation workflows for hybrid infrastructure solutions.

*You're now ready to build production-ready, parameterized infrastructure!*
