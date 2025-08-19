---
title: Testing Terraform Code for PowerShell Developers - Part 5
author: mynster
date: 2025-08-19 10:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, testing, native-testing, pester]
description: Master Terraform's native testing framework from a PowerShell perspective - write reliable infrastructure tests with familiar patterns.
---

> **📚 Series Navigation:**
>
> - [Part 1: Getting Started with Terraform for PowerShell People](/posts/GettingStartedWithTerraformForPowerShellPeople/)
> - [Part 2: Resources, Variables, and State in Terraform](/posts/ResourcesVariablesAndStateInTerraform/)
> - [Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)
> - [Part 4: Advanced State Management and Collaboration](/posts/AdvancedStateManagementAndCollaboration/)
> - **Part 5: Testing Terraform Code** ← *You are here*
> - Part 6: Terraform Modules Deep Dive *(August 26)*
> - Part 7: CI/CD with GitHub Actions *(September 2)*

## The Critical Need for Infrastructure Testing

With enterprise-grade state management and team collaboration from [Part 4](/posts/AdvancedStateManagementAndCollaboration/) now in place, it's time to address one of the most crucial aspects of professional infrastructure management: comprehensive testing.

As PowerShell developers, you understand the importance of testing - but infrastructure testing takes on even greater significance than application testing. A failed PowerShell script might cause inconvenience; failed infrastructure can cost thousands of dollars and impact business operations. The good news? Terraform v1.6+ introduced a **native testing framework** that brings testing directly into the Terraform ecosystem, making it as natural as writing the infrastructure code itself.

### Why Infrastructure Testing Matters More Than Script Testing

```powershell
# PowerShell script failure - usually reversible
function Remove-OldFiles {
    param([string]$Path, [int]$DaysOld = 30)

    Get-ChildItem $Path | Where-Object {
        $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld)
    } | Remove-Item -Force
}

# If this fails, we can usually recover files from backup
```

```hcl
# Terraform resource creation - has real cost and compliance implications
resource "azurerm_virtual_machine" "example" {
  name                = "production-vm"
  location            = "West US"
  resource_group_name = azurerm_resource_group.example.name
  vm_size             = "Standard_DS3_v2"  # $200+/month if this runs!

  # Network, storage, OS configuration...
}
```

The key differences:

- **Financial Impact**: Every resource has a cost
- **Security Implications**: Misconfigurations can expose data
- **Compliance Requirements**: Infrastructure must meet regulatory standards
- **Dependency Complexity**: Infrastructure components are interconnected
- **Cleanup Difficulty**: Some resources can't be easily deleted

## Terraform's Native Testing Framework: The PowerShell Developer's Perspective

Terraform v1.6+ introduced a **game-changing native testing framework** that brings testing directly into the Terraform ecosystem. No more external tools, complex setups, or learning new languages - you can now write tests in `.tftest.hcl` files that integrate seamlessly with your infrastructure code.

### PowerShell Pester vs. Terraform Native Testing

As PowerShell developers familiar with Pester, you'll recognize many concepts in Terraform's native testing:

| Aspect                 | PowerShell (Pester)       | Terraform Native Testing     |
| ---------------------- | ------------------------- | ---------------------------- |
| **Test Files**         | `*.Tests.ps1`             | `*.tftest.hcl`               |
| **Test Organization**  | `Describe`/`Context`/`It` | Test files with `run` blocks |
| **Assertions**         | `Should` operators        | `assert` statements          |
| **Setup/Teardown**     | `BeforeEach`/`AfterEach`  | Built into `run` blocks      |
| **Mocking**            | `Mock` commands           | Provider `override_*`        |
| **Parallel Execution** | `-Parallel` parameter     | Built-in parallelization     |
| **Integration**        | External tool/Module      | Native `terraform test`      |

### Your First Terraform Test

Let's start with a simple storage account module and see how to test it:

```hcl
# modules/storage-account/main.tf
variable "name" {
  description = "Name of the storage account"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3 and 24 characters and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "sku" {
  description = "Storage account SKU"
  type        = string
  default     = "Standard_LRS"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = split("_", var.sku)[0]
  account_replication_type = split("_", var.sku)[1]

  # Security configurations
  https_traffic_only_enabled         = true
  min_tls_version                    = "TLS1_2"
  allow_nested_items_to_be_public    = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}
```

Now let's create our first test file:

```hcl
# tests/storage-account.tftest.hcl

# Test variables - like parameters in PowerShell functions
variables {
  name                = "teststorage123"
  resource_group_name = "test-rg"
  location           = "West US 2"
  sku               = "Standard_LRS"
  tags = {
    Environment = "Test"
    Purpose     = "TerraformTesting"
  }
}

# Test 1: Validate the plan (like testing function logic without execution)
run "validate_storage_account_plan" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.name == var.name
    error_message = "Storage account name should match input variable"
  }

  assert {
    condition     = azurerm_storage_account.this.https_traffic_only_enabled == true
    error_message = "HTTPS traffic only should be enabled for security"
  }

  assert {
    condition     = azurerm_storage_account.this.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS version should be 1.2"
  }
}

# Test 2: Validate variable validation works (like testing parameter validation)
run "test_invalid_name_validation" {
  command = plan

  variables {
    name = "Invalid_Name_With_Underscores"
  }

  expect_failures = [
    var.name
  ]
}

# Test 3: Apply and validate actual resource creation
run "create_and_validate_storage_account" {
  command = apply

  assert {
    condition     = azurerm_storage_account.this.https_traffic_only_enabled == true
    error_message = "HTTPS-only should be enforced on created storage account"
  }

  assert {
    condition     = length(regexall("^https://.*", azurerm_storage_account.this.primary_blob_endpoint)) > 0
    error_message = "Blob endpoint should use HTTPS"
  }

  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].versioning_enabled == true
    error_message = "Blob versioning should be enabled"
  }

  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].delete_retention_policy[0].days == 7
    error_message = "Delete retention should be 7 days"
  }
}
```

### Running Your Tests

Just like running Pester tests with `Invoke-Pester`, you run Terraform tests with:

```bash
# Run all tests in the current directory
terraform test

# Run specific test file
terraform test tests/storage-account.tftest.hcl

# Run tests with verbose output (like Pester -Detailed)
terraform test -verbose

# You can also set the environment variable TF_LOG to get additional output from terraform available options listed here
# https://developer.hashicorp.com/terraform/internals/debugging
```

## Advanced Native Testing Patterns

Just like testing individual PowerShell functions, we can create focused test scenarios for specific aspects of our infrastructure. Here's how to build comprehensive test suites:

```hcl
# tests/comprehensive-storage.tftest.hcl

variables {
  resource_group_name = "test-rg"
  location           = "West US 2"
}

# Test 1: Basic functionality with default values
run "test_default_configuration" {
  command = plan

  variables {
    name = "defaultstoragetest"
  }

  assert {
    condition     = azurerm_storage_account.this.account_tier == "Standard"
    error_message = "Default SKU should result in Standard tier"
  }

  assert {
    condition     = azurerm_storage_account.this.account_replication_type == "LRS"
    error_message = "Default SKU should result in LRS replication"
  }
}

# Test 2: Premium storage configuration
run "test_premium_storage" {
  command = plan

  variables {
    name = "premiumstoragetest"
    sku  = "Premium_LRS"
  }

  assert {
    condition     = azurerm_storage_account.this.account_tier == "Premium"
    error_message = "Premium SKU should result in Premium tier"
  }

  assert {
    condition     = azurerm_storage_account.this.account_replication_type == "LRS"
    error_message = "Premium_LRS should result in LRS replication"
  }
}

# Test 3: Security configurations are enforced
run "test_security_defaults" {
  command = plan

  variables {
    name = "securitystoragetest"
  }

  assert {
    condition     = azurerm_storage_account.this.https_traffic_only_enabled == true
    error_message = "HTTPS-only traffic must be enabled by default"
  }

  assert {
    condition     = azurerm_storage_account.this.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS version must be 1.2"
  }

  assert {
    condition     = azurerm_storage_account.this.allow_nested_items_to_be_public == false
    error_message = "Public blob access must be disabled by default"
  }
}

# Test 4: Tag inheritance works correctly
run "test_tag_handling" {
  command = plan

  variables {
    name = "tagstoragetest"
    tags = {
      Environment = "Testing"
      Project     = "TerraformSeries"
      Owner       = "Platform Team"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.tags["Environment"] == "Testing"
    error_message = "Environment tag should be properly set"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["Project"] == "TerraformSeries"
    error_message = "Project tag should be properly set"
  }
}

# Test 5: Variable validation catches invalid inputs
run "test_name_validation_failure" {
  command = plan

  variables {
    name = "Invalid_Storage_Name_With_Underscores"
  }

  expect_failures = [
    var.name
  ]
}

# Test 6: Apply test to verify actual resource creation
run "test_actual_deployment" {
  command = apply

  variables {
    name = "deployteststorage"
    tags = {
      Purpose = "ActualDeploymentTest"
    }
  }

  assert {
    condition     = output.storage_account_name == "deployteststorage"
    error_message = "Output should match the input name"
  }

  assert {
    condition     = length(regexall("^https://.*", output.primary_blob_endpoint)) > 0
    error_message = "Blob endpoint should use HTTPS"
  }
}
```

### Provider Mocking for Fast Unit Tests

One of the most powerful features is the ability to mock providers for lightning-fast unit tests. This is like using `Mock` in Pester to test logic without external dependencies:

```hcl
# tests/unit-tests.tftest.hcl

# Mock the Azure provider for isolated testing
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      name                     = "mockedstorageaccount"
      location                 = "East US"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      https_traffic_only_enabled = true
      min_tls_version         = "TLS1_2"

      primary_blob_endpoint = "https://mockedstorageaccount.blob.core.windows.net/"

      tags = {}
    }
  }
}

variables {
  name                = "mockedtest"
  resource_group_name = "mock-rg"
  location           = "East US"
}

run "test_logic_without_azure_calls" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.name == var.name
    error_message = "Storage account name should use the variable value"
  }

  assert {
    condition     = split("_", var.sku)[0] == azurerm_storage_account.this.account_tier
    error_message = "Account tier should be derived from SKU variable"
  }
}

run "test_tag_merging_logic" {
  command = plan

  variables {
    tags = {
      Environment = "Test"
      Project     = "Mock"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.tags["Environment"] == "Test"
    error_message = "Tags should be properly merged"
  }

  assert {
    condition     = azurerm_storage_account.this.tags["Project"] == "Mock"
    error_message = "Custom tags should be applied"
  }
}
```

### Integration Testing with Dependencies

Test how multiple resources work together, similar to integration tests in PowerShell:

```hcl
# tests/integration.tftest.hcl

variables {
  environment = "integration-test"
  location    = "West US 2"
}

run "setup_resource_group" {
  command = apply

  module {
    source = "./tests/fixtures/resource-group"
  }

  variables {
    name     = "integration-test-rg"
    location = var.location
  }
}

run "test_storage_with_real_rg" {
  command = apply

  variables {
    name                = "integrationteststorage"
    resource_group_name = run.setup_resource_group.resource_group_name
    location           = run.setup_resource_group.location
  }

  assert {
    condition     = azurerm_storage_account.this.resource_group_name == run.setup_resource_group.resource_group_name
    error_message = "Storage account should be in the correct resource group"
  }

  assert {
    condition     = azurerm_storage_account.this.location == run.setup_resource_group.location
    error_message = "Storage account should be in the same location as resource group"
  }
}

run "test_storage_connectivity" {
  command = apply

  # Test that we can actually interact with the storage account
  assert {
    condition     = can(regex("^https://.*\\.blob\\.core\\.windows\\.net/$", output.primary_blob_endpoint))
    error_message = "Blob endpoint should be a valid Azure Storage URL"
  }
}
```

## Side-by-Side Testing Patterns for PowerShell Developers

As a PowerShell developer moving to Terraform, you'll appreciate seeing direct comparisons between testing approaches. Let's examine how common PowerShell testing patterns translate to Terraform's native testing framework.

### 1. Parameter Validation Tests

**In PowerShell (Pester):**

```powershell
# Storage account name validation in Pester
Describe "New-StorageAccount parameter validation" {
    Context "Name parameter validation" {
        It "Should reject empty names" {
            { New-StorageAccount -Name "" -ResourceGroup "test-rg" } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }

        It "Should reject names longer than 24 characters" {
            { New-StorageAccount -Name "thisnameiswaylongerthanthetwentyfourcharacterlimit" } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }

        It "Should reject names with invalid characters" {
            { New-StorageAccount -Name "invalid-name-with-dashes" } |
                Should -Throw "Cannot validate argument on parameter 'Name'"
        }

        It "Should accept valid boundary cases" {
            # Minimum valid length
            { New-StorageAccount -Name "abc" -ResourceGroup "test-rg" } | Should -Not -Throw

            # Maximum valid length
            { New-StorageAccount -Name "abcdefghijklmnopqrstuvwx" -ResourceGroup "test-rg" } | Should -Not -Throw
        }
    }
}
```

**In Terraform:**

```hcl
# tests/validation.tftest.hcl

# Testing variable validation in Terraform
run "test_invalid_names" {
  command = plan

  # Test invalid empty name
  variables {
    name = ""
  }
  expect_failures = [var.name]
}

run "test_name_too_long" {
  command = plan
  variables {
    name = "thisnameiswaylongerthanthetwentyfourcharacterlimit"
  }
  expect_failures = [var.name]
}

run "test_name_with_special_chars" {
  command = plan
  variables {
    name = "invalid-name-with-dashes"
  }
  expect_failures = [var.name]
}

run "test_valid_boundary_cases" {
  command = plan
  variables {
    name                = "abc"  # Minimum valid length
    resource_group_name = "test-rg"
    location           = "West US 2"
  }
  # Should proceed without error (implicit test)
}
```

### 2. Testing Business Logic and Conditional Behavior

**In PowerShell (Pester):**

```powershell
# Testing environment-specific configurations
Describe "Get-StorageAccountConfig" {
    Context "Environment-specific configurations" {
        It "Should use LRS for development environments" {
            $config = Get-StorageAccountConfig -Environment "development"
            $config.ReplicationType | Should -Be "LRS"
        }

        It "Should use GRS for production environments" {
            $config = Get-StorageAccountConfig -Environment "production"
            $config.ReplicationType | Should -Be "GRS"
        }
    }

    Context "Feature flag configurations" {
        It "Should enable deletion retention when backup is enabled" {
            $config = Get-StorageAccountConfig -EnableBackup $true
            $config.DeleteRetentionPolicy.Enabled | Should -Be $true
            $config.DeleteRetentionPolicy.Days | Should -BeGreaterThan 0
        }

        It "Should set minimal retention when backup is disabled" {
            $config = Get-StorageAccountConfig -EnableBackup $false
            $config.DeleteRetentionPolicy.Days | Should -Be 1
        }
    }
}
```

**In Terraform:**

```hcl
# tests/conditional-logic.tftest.hcl

# Testing environment-based configurations
run "test_environment_configurations" {
  command = plan

  # Test development environment
  variables {
    name        = "devstoragetest"
    environment = "development"
  }

  assert {
    condition     = azurerm_storage_account.this.account_replication_type == "LRS"
    error_message = "Development should use LRS for cost savings"
  }
}

run "test_production_configuration" {
  command = plan
  variables {
    name        = "prodstoragetest"
    environment = "production"
  }

  assert {
    condition     = azurerm_storage_account.this.account_replication_type == "GRS"
    error_message = "Production should use GRS for redundancy"
  }
}

# Testing feature flags
run "test_backup_configurations" {
  command = plan

  variables {
    name          = "backupstoragetest"
    enable_backup = true
  }

  assert {
    condition     = length(azurerm_storage_account.this.blob_properties[0].delete_retention_policy) > 0
    error_message = "Backup should be configured when enabled"
  }
}
```

## Test Organization and Best Practices

### Test File Structure

Organize your tests like you would organize PowerShell test files:

```plaintext
# Your main repo could contain multiple modules so we are just going with the storage accounts as an example
modules/storage-account/
├── main.tf
├── variables.tf
└── outputs.tf
tests/
└── tests/
    └── storage-account.tftest.hcl # Containing all of your tests for the storage-account test

# If you wanted to you could also have multiple tests and do it a bit more like Pester with unit and integration tests instead so your files/folder could look like this
└── tests/
    ├── unit-storage-account.tftest.hcl
    └── integration-storage-account.tftest.hcl
# This could allow you to split the tests up further
```

### CI/CD Integration

```yaml
# .github/workflows/terraform-test.yml
name: 'Terraform Tests'

on:
  push:

permissions:
  contents: read # Needed to clone repo

jobs:
  terraform-tests:
    name: 'Terraform Tests'
    runs-on: ubuntu-latest

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v5

    # Install the latest version of Terraform CLI
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3

    # Initialize a new or existing Terraform working directory, downloading modules, etc.
    - name: Terraform Init
      run: terraform init

    # Checks that all Terraform configuration files adhere to a canonical format
    - name: Terraform Format
      run: terraform fmt -check -recursive

    - name: Terraform Test
      run: terraform test
```

## Key Takeaways for PowerShell Developers

Testing Terraform infrastructure with the native framework represents a significant leap forward in infrastructure reliability and development velocity. As PowerShell professionals transitioning to Terraform, you now have access to testing capabilities that are:

### Familiar Yet Powerful

- **Native Integration**: No external tools or languages required
- **Familiar Patterns**: Assertions, mocking, and test organization similar to Pester

### Cost-Effective and Safe

- **Provider Mocking**: Test logic without creating expensive cloud resources
- **Automatic Cleanup**: Built-in resource cleanup prevents cost surprises
- **Fast Feedback**: Unit tests run in seconds, not minutes

### Enterprise-Ready

- **CI/CD Integration**: Native support in all major CI/CD platforms
- **Parallel Execution**: Tests run concurrently for faster feedback
- **Comprehensive Coverage**: From unit tests to full integration scenarios

### Best Practices Checklist

**Start with mocked unit tests** for fast feedback on logic
**Use descriptive test names** that explain what you're testing
**Integrate with CI/CD** for automated testing on every change
**Clean up resources** automatically to control costs

### What's Next?

In Part 6 Terraform Modules DeepDive, we'll explore how to build production-ready Terraform modules that incorporate these testing patterns from the ground up. You'll learn how to structure modules for testability and create reusable infrastructure components that your team can trust.

The combination of Terraform's declarative infrastructure and native testing framework provides PowerShell developers with a robust, familiar, and cost-effective path to infrastructure automation excellence. Your journey from imperative scripts to tested, declarative infrastructure is well underway!
