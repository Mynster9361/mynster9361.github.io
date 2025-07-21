---
title: Testing Terraform Code for PowerShell Developers - Part 5
author: mynster
date: 2025-08-12 10:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, testing, native-testing, pester]
description: Master Terraform's native testing framework from a PowerShell perspective - write reliable infrastructure tests with familiar patterns.
---

> **📚 Series Navigation:**
> - [Part 1: Getting Started with Terraform for PowerShell People](/posts/GettingStartedWithTerraformForPowerShellPeople/)
> - [Part 2: Resources, Variables, and State in Terraform](/posts/ResourcesVariablesAndStateInTerraform/)
> - [Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)
> - [Part 4: Advanced State Management and Collaboration](/posts/AdvancedStateManagementAndCollaboration/)
> - **Part 5: Testing Terraform Code** ← *You are here*
> - Part 6: Terraform Modules Deep Dive *(August 19)*
> - Part 7: CI/CD with GitHub Actions *(August 26)*

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
| **Integration**        | External tool             | Native `terraform test`      |

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

# Run tests without cleanup (for debugging)
terraform test -no-cleanup
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

### PowerShell Integration with Native Testing

You can enhance native testing with PowerShell automation:

```powershell
# scripts/Test-TerraformModule.ps1

function Invoke-TerraformNativeTesting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModulePath,
        
        [string]$TestPath = "tests/",
        [hashtable]$Variables = @{},
        [switch]$Verbose,
        [switch]$NoCleanup,
        [int]$Parallelism = 10
    )
    
    Write-Host "Running Terraform native tests for module: $ModulePath" -ForegroundColor Cyan
    
    # Change to module directory
    Push-Location $ModulePath
    try {
        # Build terraform test command
        $args = @("test")
        
        if (Test-Path $TestPath) {
            $args += $TestPath
        }
        
        if ($Verbose) {
            $args += "-verbose"
        }
        
        if ($NoCleanup) {
            $args += "-no-cleanup"
        }
        
        $args += "-parallelism=$Parallelism"
        
        # Add variables
        foreach ($var in $Variables.GetEnumerator()) {
            $args += "-var=$($var.Key)=$($var.Value)"
        }
        
        Write-Host "Executing: terraform $($args -join ' ')" -ForegroundColor DarkGray
        
        # Run the tests
        $output = & terraform $args
        $exitCode = $LASTEXITCODE
        
        # Parse and display results
        if ($exitCode -eq 0) {
            Write-Host "✓ All tests passed!" -ForegroundColor Green
            
            # Parse output for test summary
            $testResults = $output | Where-Object { $_ -match "^\s*(✓|✗)" }
            foreach ($result in $testResults) {
                if ($result -match "✓") {
                    Write-Host "  $result" -ForegroundColor Green
                } else {
                    Write-Host "  $result" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "✗ Some tests failed!" -ForegroundColor Red
            $output | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        }
        
        return $exitCode -eq 0
        
    } catch {
        Write-Error "Failed to run Terraform tests: $_"
        return $false
    } finally {
        Pop-Location
    }
}

# Enhanced function with test result reporting
function Get-TerraformTestResults {
    param(
        [Parameter(Mandatory)]
        [string]$ModulePath,
        [string]$OutputFormat = "json"
    )
    
    Push-Location $ModulePath
    try {
        # Run tests with JSON output for parsing
        $testOutput = terraform test -json | ConvertFrom-Json
        
        $results = @{
            TotalTests = 0
            PassedTests = 0
            FailedTests = 0
            TestDetails = @()
        }
        
        foreach ($line in $testOutput) {
            if ($line."@level" -eq "info" -and $line."@message" -match "test.*passed|failed") {
                $results.TotalTests++
                
                if ($line."@message" -match "passed") {
                    $results.PassedTests++
                    $status = "Passed"
                } else {
                    $results.FailedTests++
                    $status = "Failed"
                }
                
                $results.TestDetails += @{
                    Name = $line.test_file
                    Status = $status
                    Message = $line."@message"
                }
            }
        }
        
        return $results
        
    } finally {
        Pop-Location
    }
}

# Usage examples
Invoke-TerraformNativeTesting -ModulePath "./modules/storage-account" -Verbose
$results = Get-TerraformTestResults -ModulePath "./modules/storage-account"
Write-Host "Test Summary: $($results.PassedTests)/$($results.TotalTests) passed" -ForegroundColor $(if ($results.FailedTests -eq 0) { "Green" } else { "Red" })
```

## Essential Testing Patterns for PowerShell Developers

### 1. Input Validation Testing (Like Parameter Validation in PowerShell)

```hcl
# tests/validation.tftest.hcl

# Test various invalid inputs
run "test_empty_name" {
  command = plan
  
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

# Test valid boundary cases
run "test_minimum_length_name" {
  command = plan
  
  variables {
    name = "abc"  # 3 characters - minimum valid
  }
  
  assert {
    condition     = azurerm_storage_account.this.name == "abc"
    error_message = "Minimum length name should be accepted"
  }
}

run "test_maximum_length_name" {
  command = plan
  
  variables {
    name = "abcdefghijklmnopqrstuvwx"  # 24 characters - maximum valid
  }
  
  assert {
    condition     = azurerm_storage_account.this.name == "abcdefghijklmnopqrstuvwx"
    error_message = "Maximum length name should be accepted"
  }
}
```

### 2. Conditional Logic Testing (Like If/Switch Statements in PowerShell)

```hcl
# tests/conditional-logic.tftest.hcl

# Test environment-based configurations
run "test_development_environment" {
  command = plan
  
  variables {
    name        = "devstoragetest"
    environment = "development"
  }
  
  assert {
    condition     = azurerm_storage_account.this.account_replication_type == "LRS"
    error_message = "Development should use LRS for cost savings"
  }
}

run "test_production_environment" {
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

# Test feature flags
run "test_backup_enabled" {
  command = plan
  
  variables {
    name           = "backupstoragetest"
    enable_backup = true
  }
  
  assert {
    condition     = length(azurerm_storage_account.this.blob_properties[0].delete_retention_policy) > 0
    error_message = "Backup should be configured when enabled"
  }
}

run "test_backup_disabled" {
  command = plan
  
  variables {
    name           = "nobackupstoragetest"
    enable_backup = false
  }
  
  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].delete_retention_policy[0].days == 1
    error_message = "Minimal retention when backup is disabled"
  }
}
```

### 3. Error Handling and Edge Cases (Like Try/Catch in PowerShell)

```hcl
# tests/edge-cases.tftest.hcl

# Test resource naming conflicts
run "test_duplicate_name_handling" {
  command = plan
  
  variables {
    name = "duplicatetest"
  }
  
  # First deployment should succeed
  assert {
    condition     = azurerm_storage_account.this.name == "duplicatetest"
    error_message = "First deployment should work"
  }
}

# Test with minimal required parameters
run "test_minimal_configuration" {
  command = plan
  
  variables {
    name                = "minimaltest"
    resource_group_name = "test-rg"
    location           = "West US 2"
  }
  
  assert {
    condition     = azurerm_storage_account.this.sku == "Standard_LRS"
    error_message = "Should use default SKU when not specified"
  }
  
  assert {
    condition     = length(azurerm_storage_account.this.tags) == 0
    error_message = "Should have no tags when not specified"
  }
}

# Test with maximum configuration
run "test_maximum_configuration" {
  command = plan
  
  variables {
    name                = "maximaltest"
    resource_group_name = "test-rg"
    location           = "West US 2"
    sku               = "Premium_ZRS"
    tags = {
      Environment = "Production"
      Project     = "MaxTest"
      Owner       = "Platform"
      CostCenter  = "IT-Infrastructure"
      Backup      = "Daily"
    }
  }
  
  assert {
    condition     = azurerm_storage_account.this.account_tier == "Premium"
    error_message = "Should handle Premium tier correctly"
  }
  
  assert {
    condition     = length(azurerm_storage_account.this.tags) == 5
    error_message = "Should apply all provided tags"
  }
}
```

## Test Organization and Best Practices

### Test File Structure

Organize your tests like you would organize PowerShell test files:

```
modules/storage-account/
├── main.tf
├── variables.tf
├── outputs.tf
└── tests/
    ├── unit.tftest.hcl           # Fast, mocked tests
    ├── integration.tftest.hcl    # Tests with real resources
    ├── validation.tftest.hcl     # Input validation tests
    ├── security.tftest.hcl       # Security compliance tests
    └── fixtures/                 # Test helper modules
        └── resource-group/
            ├── main.tf
            └── outputs.tf
```

### CI/CD Integration

```yaml
# .github/workflows/terraform-test.yml
name: Terraform Module Testing

on:
  pull_request:
    paths:
      - 'modules/**/*.tf'
      - 'modules/**/*.tftest.hcl'

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: [storage-account, networking, compute]
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.8.0"
      
      - name: Run Unit Tests
        run: |
          cd modules/${{ matrix.module }}
          terraform test tests/unit.tftest.hcl
      
      - name: Run Integration Tests
        run: |
          cd modules/${{ matrix.module }}
          terraform test tests/integration.tftest.hcl
        env:
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
```

## Key Takeaways for PowerShell Developers

Testing Terraform infrastructure with the native framework represents a significant leap forward in infrastructure reliability and development velocity. As PowerShell professionals transitioning to Terraform, you now have access to testing capabilities that are:

### Familiar Yet Powerful

- **Native Integration**: No external tools or languages required
- **Familiar Patterns**: Assertions, mocking, and test organization similar to Pester
- **PowerShell-Friendly**: Easy integration with your existing PowerShell automation

### Cost-Effective and Safe

- **Provider Mocking**: Test logic without creating expensive cloud resources
- **Automatic Cleanup**: Built-in resource cleanup prevents cost surprises
- **Fast Feedback**: Unit tests run in seconds, not minutes

### Enterprise-Ready

- **CI/CD Integration**: Native support in all major CI/CD platforms
- **Parallel Execution**: Tests run concurrently for faster feedback
- **Comprehensive Coverage**: From unit tests to full integration scenarios

### Best Practices Checklist

✅ **Start with mocked unit tests** for fast feedback on logic  
✅ **Use descriptive test names** that explain what you're testing  
✅ **Test both happy path and edge cases** like you would in Pester  
✅ **Organize tests by concern** (validation, security, integration)  
✅ **Integrate with CI/CD** for automated testing on every change  
✅ **Clean up resources** automatically to control costs  

### What's Next?

In [Part 6](/posts/TerraformModulesDeepDive/), we'll explore how to build production-ready Terraform modules that incorporate these testing patterns from the ground up. You'll learn how to structure modules for testability and create reusable infrastructure components that your team can trust.

The combination of Terraform's declarative infrastructure and native testing framework provides PowerShell developers with a robust, familiar, and cost-effective path to infrastructure automation excellence. Your journey from imperative scripts to tested, declarative infrastructure is well underway!
```

#### 2. Provider Mocking and Overrides

```hcl
# tests/unit.tftest.hcl

# Mock the Azure provider for unit testing
override_resource {
  target = azurerm_resource_group.main
  values = {
    name     = "test-rg"
    location = "East US"
    id       = "/subscriptions/test/resourceGroups/test-rg"
  }
}

override_data {
  target = data.azurerm_client_config.current
  values = {
    tenant_id = "test-tenant-id"
    object_id = "test-object-id"
  }
}

run "unit_test_logic" {
  command = plan

  assert {
    condition     = azurerm_storage_account.main.name == "test${data.azurerm_client_config.current.object_id}"
    error_message = "Storage account name should include object ID"
  }
}
```

#### 3. Variable Testing and Validation

```hcl
# tests/variables.tftest.hcl

# Test with minimal variables
run "test_defaults" {
  command = plan
  
  variables {
    resource_group_name = "test-rg"
  }

  assert {
    condition     = var.location == "East US"
    error_message = "Default location should be East US"
  }
}

# Test with custom variables
run "test_custom_config" {
  command = plan
  
  variables {
    resource_group_name = "custom-rg"
    location           = "West US 2"
    tags = {
      Environment = "Production"
      Owner      = "Platform Team"
    }
  }

  assert {
    condition     = azurerm_resource_group.main.tags["Environment"] == "Production"
    error_message = "Environment tag should be set correctly"
  }
}

# Test validation rules
run "test_invalid_location" {
  command = plan
  
  variables {
    resource_group_name = "test-rg"
    location           = "Invalid Location"
  }

  expect_failures = [
    var.location
  ]
}
```

#### 4. Module Testing

```hcl
# tests/module.tftest.hcl

# Test the module with different configurations
run "test_development_config" {
  command = apply
  
  variables {
    environment = "dev"
    vm_size    = "Standard_B1s"
  }

  module {
    source = "./modules/webapp"
  }

  assert {
    condition     = module.webapp.app_service_plan_sku == "F1"
    error_message = "Development should use F1 SKU"
  }
}

run "test_production_config" {
  command = plan
  
  variables {
    environment = "prod"
    vm_size    = "Standard_D2s_v3"
  }

  module {
    source = "./modules/webapp"
  }

  assert {
    condition     = module.webapp.app_service_plan_sku == "P1v2"
    error_message = "Production should use P1v2 SKU"
  }

  assert {
    condition     = module.webapp.backup_enabled == true
    error_message = "Production should have backup enabled"
  }
}
```

### Running Native Tests

#### Basic Commands

```bash
# Run all tests
terraform test

# Run specific test file
terraform test tests/basic.tftest.hcl

# Run with verbose output
terraform test -verbose

# Run tests in parallel (default)
terraform test -parallelism=10

# Run tests with custom variables
terraform test -var="environment=staging"
```

#### PowerShell Integration

```powershell
# PowerShell wrapper for Terraform testing
function Invoke-TerraformTest {
    param(
        [string]$TestPath = "tests/",
        [hashtable]$Variables = @{},
        [switch]$Verbose,
        [int]$Parallelism = 10
    )
    
    $args = @("test")
    
    if ($TestPath) {
        $args += $TestPath
    }
    
    if ($Verbose) {
        $args += "-verbose"
    }
    
    $args += "-parallelism=$Parallelism"
    
    foreach ($var in $Variables.GetEnumerator()) {
        $args += "-var=$($var.Key)=$($var.Value)"
    }
    
    & terraform $args
}

# Usage examples
Invoke-TerraformTest -Verbose
Invoke-TerraformTest -TestPath "tests/unit.tftest.hcl" -Variables @{environment="test"}
```

### Test Organization Patterns

#### 1. Hierarchical Test Structure

```
tests/
├── unit/
│   ├── variables.tftest.hcl
│   ├── resources.tftest.hcl
│   └── outputs.tftest.hcl
├── integration/
│   ├── networking.tftest.hcl
│   ├── compute.tftest.hcl
│   └── storage.tftest.hcl
├── e2e/
│   ├── full-deployment.tftest.hcl
│   └── disaster-recovery.tftest.hcl
└── performance/
    └── load-testing.tftest.hcl
```

#### 2. Environment-Specific Tests

```hcl
# tests/environments/dev.tftest.hcl
variables {
  environment = "dev"
}

provider "azurerm" {
  features {}
  subscription_id = "dev-subscription-id"
}

run "dev_environment_test" {
  command = apply

  assert {
    condition     = azurerm_app_service_plan.main.sku[0].tier == "Free"
    error_message = "Dev environment should use Free tier"
  }
}
```

### Advanced Features (v1.7+)

#### 1. Test Suites and Dependencies

```hcl
# tests/suite.tftest.hcl

# Define test suite with dependencies
test_suite "webapp_deployment" {
  description = "Complete web application deployment testing"
  
  run "infrastructure_validation" {
    command = plan
    # ... assertions
  }
  
  run "security_compliance" {
    depends_on = [run.infrastructure_validation]
    command = plan
    # ... security assertions
  }
  
  run "deployment_test" {
    depends_on = [run.infrastructure_validation, run.security_compliance]
    command = apply
    # ... deployment assertions
  }
}
```

#### 2. Custom Assertions and Functions

```hcl
# tests/custom-assertions.tftest.hcl

locals {
  # Custom validation functions
  is_valid_subnet = can(cidrsubnet(var.address_space, 8, 1))
  is_secure_storage = alltrue([
    azurerm_storage_account.main.enable_https_traffic_only,
    azurerm_storage_account.main.min_tls_version == "TLS1_2"
  ])
}

run "custom_validations" {
  command = plan

  assert {
    condition     = local.is_valid_subnet
    error_message = "Address space must allow subnet creation"
  }

  assert {
    condition     = local.is_secure_storage
    error_message = "Storage account must be secure (HTTPS only, TLS 1.2+)"
  }
}
```

### Enterprise Integration Patterns

#### 1. CI/CD Integration

```yaml
# .github/workflows/terraform-test.yml
name: Terraform Tests

on:
  pull_request:
    paths:
      - '**.tf'
      - '**.tftest.hcl'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.7.0"
      
      - name: Run Unit Tests
        run: terraform test tests/unit/
      
      - name: Run Integration Tests
        run: terraform test tests/integration/
        env:
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
```

#### 2. PowerShell Test Orchestration

```powershell
# scripts/Test-Infrastructure.ps1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("unit", "integration", "e2e", "all")]
    [string]$TestType = "all",
    
    [Parameter(Mandatory = $false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory = $false)]
    [switch]$GenerateReport
)

function Test-TerraformConfiguration {
    param(
        [string]$TestType,
        [string]$Environment
    )
    
    $testResults = @()
    
    switch ($TestType) {
        "unit" {
            Write-Host "Running unit tests..." -ForegroundColor Yellow
            $result = terraform test tests/unit/
            $testResults += @{ Type = "Unit"; Result = $LASTEXITCODE }
        }
        "integration" {
            Write-Host "Running integration tests..." -ForegroundColor Yellow
            $result = terraform test tests/integration/ -var="environment=$Environment"
            $testResults += @{ Type = "Integration"; Result = $LASTEXITCODE }
        }
        "e2e" {
            Write-Host "Running end-to-end tests..." -ForegroundColor Yellow
            $result = terraform test tests/e2e/ -var="environment=$Environment"
            $testResults += @{ Type = "E2E"; Result = $LASTEXITCODE }
        }
        "all" {
            foreach ($type in @("unit", "integration", "e2e")) {
                Test-TerraformConfiguration -TestType $type -Environment $Environment
            }
        }
    }
    
    return $testResults
}

# Generate test report
if ($GenerateReport) {
    $results = Test-TerraformConfiguration -TestType $TestType -Environment $Environment
    $results | ConvertTo-Json | Out-File "test-results.json"
    Write-Host "Test report generated: test-results.json" -ForegroundColor Green
}
```

### Best Practices for Native Testing

#### 1. Test Naming and Organization

```hcl
# Good: Descriptive test names
run "validate_storage_encryption_at_rest" {
  command = plan
  # ... test logic
}

# Bad: Generic test names
run "test1" {
  command = plan
  # ... test logic
}
```

#### 2. Assertion Granularity

```hcl
# Good: Specific, focused assertions
assert {
  condition     = azurerm_storage_account.main.enable_https_traffic_only == true
  error_message = "Storage account must enforce HTTPS traffic only"
}

assert {
  condition     = azurerm_storage_account.main.min_tls_version == "TLS1_2"
  error_message = "Storage account must use TLS 1.2 or higher"
}

# Bad: Combined assertions that are hard to debug
assert {
  condition = alltrue([
    azurerm_storage_account.main.enable_https_traffic_only,
    azurerm_storage_account.main.min_tls_version == "TLS1_2",
    azurerm_storage_account.main.public_network_access_enabled == false
  ])
  error_message = "Storage account security validation failed"
}
```

#### 3. Variable Management

```hcl
# tests/variables.auto.tfvars
# Common variables for all tests
environment = "test"
location    = "East US"

# tests/integration.tftest.hcl
variables {
  # Test-specific overrides
  resource_group_name = "integration-test-rg"
  vm_count           = 2
}
```

### Performance and Optimization

#### 1. Parallel Test Execution

```bash
# Run tests in parallel (default behavior)
terraform test -parallelism=5

# Sequential execution for debugging
terraform test -parallelism=1
```

#### 2. Test Caching and State Management

```hcl
# tests/cached.tftest.hcl

# Use consistent state for faster testing
run "setup_infrastructure" {
  command = apply
  
  # This run creates the base infrastructure
}

run "test_feature_a" {
  # Reuses the state from setup_infrastructure
  command = plan
  
  variables {
    feature_a_enabled = true
  }
}

run "test_feature_b" {
  # Also reuses the same state
  command = plan
  
  variables {
    feature_b_enabled = true
  }
}
```

### Troubleshooting Native Tests

#### Common Issues and Solutions

1. **Test Isolation Problems**

```hcl
# Problem: Tests interfering with each other
run "test1" {
  command = apply
  # Creates resources that affect test2
}

run "test2" {
  command = apply
  # Fails because of test1's resources
}

# Solution: Use unique naming or cleanup
run "test1" {
  command = apply
  
  variables {
    name_prefix = "test1"
  }
}

run "test2" {
  command = apply
  
  variables {
    name_prefix = "test2"
  }
}
```

2. **Provider Configuration Issues**

```hcl
# Problem: Tests using wrong subscription
run "test_wrong_sub" {
  command = apply
  # Uses default provider configuration
}

# Solution: Override provider configuration
override_provider "azurerm" {
  subscription_id = "test-subscription-id"
  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
```

## Key Takeaways: Your Infrastructure Testing Journey

Testing Terraform code is essential for maintaining reliable, secure, and scalable infrastructure. As PowerShell professionals, you already understand the value of testing—now you can apply these same principles to your infrastructure code with even more sophistication.

### Testing Strategy Evolution

| Test Type               | Native Framework                 | PowerShell Equivalent       |
| ----------------------- | -------------------------------- | --------------------------- |
| **Unit Testing**        | `.tftest.hcl` files with mocking | `Pester` unit tests         |
| **Integration Testing** | Multi-run `.tftest.hcl` files    | `Pester` integration tests  |
| **End-to-End Testing**  | Combined native + monitoring     | End-to-end PowerShell tests |

### The New Testing Paradigm (v1.6+)

The introduction of Terraform's native testing framework fundamentally changes how we approach infrastructure testing:

- **Reduced Complexity**: No need for external languages (Go, Ruby)
- **Faster Feedback**: Native integration with Terraform workflow
- **Better Debugging**: Native Terraform error messages and debugging
- **Simplified CI/CD**: Single tool for development and testing

### Migration Roadmap

1. **Start with Native Unit Tests** (Terraform v1.6+)
   - Create `.tftest.hcl` files for module validation
   - Use provider mocking for fast, isolated tests
   - Zero cost, immediate value

2. **Implement Integration Testing** (Terraform v1.6+)
   - Multi-run test scenarios with real infrastructure
   - Cost-conscious with automatic cleanup

3. **Build End-to-End Tests** (Terraform v1.7+)
   - Complete infrastructure scenarios
   - Chaos engineering and disaster recovery testing

4. **Optimize and Scale** (Ongoing)
   - Parallel test execution
   - Test result caching and optimization

### Best Practices Checklist

- ✅ **Prefer native testing** for new projects (Terraform v1.6+)
- ✅ **Use consistent naming** for test files (`.tftest.hcl`)
- ✅ **Test in isolation** using provider mocking and overrides
- ✅ **Organize tests hierarchically** (unit → integration → e2e)
- ✅ **Test both success and failure scenarios** using `expect_failures`
- ✅ **Integrate testing into CI/CD** with parallel execution
- ✅ **Monitor and alert** on infrastructure changes
- ✅ **Document test scenarios** and expected outcomes
- ✅ **Clean up test resources** automatically to control costs
- ✅ **Version your test code** alongside infrastructure code

## Conclusion and Next Steps

In this fifth part of our PowerShell-to-Terraform series, you've mastered comprehensive testing strategies that ensure your infrastructure is reliable, cost-effective, and enterprise-ready:

**What We've Accomplished:**
1. **Native Testing Framework**: Terraform v1.6+ `.tftest.hcl` syntax and advanced patterns
2. **PowerShell Integration**: Leveraging Pester skills for infrastructure validation
3. **Enterprise Patterns**: Cost management, compliance testing, and CI/CD integration
4. **Advanced Scenarios**: Contract testing, chaos engineering, and disaster recovery validation

**PowerShell Developer Advantages:**
Your Pester testing experience translates directly to infrastructure testing, but with enhanced capabilities:
- Similar test organization and assertion patterns
- More sophisticated mocking and isolation capabilities
- Built-in cost management and resource cleanup
- Enterprise compliance and security validation

**Testing Maturity Achieved:**

| **Testing Level** | **PowerShell Equivalent** | **Terraform Implementation** | **Enterprise Value**      |
| ----------------- | ------------------------- | ---------------------------- | ------------------------- |
| **Unit Testing**  | Pester                    | `.tftest.hcl` + mocking      | Fast feedback loops       |
| **Integration**   | Pester + actual calls     | Multi-run scenarios          | Real-world validation     |
| **End-to-End**    | Complex Pester suites     | Complete infrastructure      | Business scenario testing |
| **Performance**   | Custom scripts            | Chaos engineering            | Resilience & recovery     |

**Infrastructure Maturity Progression:**
✅ Foundation → ✅ Variables & State → ✅ Advanced Integration → ✅ Enterprise Collaboration → ✅ Comprehensive Testing → Modules → CI/CD

**Coming Next:**
In [Part 6](/posts/TerraformModulesDeepDive/), we'll explore how to create reusable, testable infrastructure components using advanced module patterns - bringing together everything we've learned about variables, state management, collaboration, and testing into production-ready, shareable modules.

*Your infrastructure now has enterprise-grade testing coverage with automated validation!*
