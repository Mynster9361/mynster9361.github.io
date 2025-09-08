---
title: Terraform CI/CD with GitHub Actions - Part 7
author: mynster
date: 2025-09-09 10:30:00 +0100
categories: [Infrastructure, Terraform]
tags: [terraform, powershell, ci/cd, github actions, devops]
description: Learn how to implement comprehensive CI/CD pipelines for Terraform using GitHub Actions, with testing, automated plans, and deployment workflows.
---

> **📚 Series Navigation:**
>
> - [Part 1: Getting Started with Terraform for PowerShell People](/posts/GettingStartedWithTerraformForPowerShellPeople/)
> - [Part 2: Resources, Variables, and State in Terraform (July 22)](/posts/ResourcesVariablesAndStateInTerraform/)
> - [Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)
> - [Part 4: Advanced State Management and Collaboration](/posts/AdvancedStateManagementAndCollaboration/)
> - [Part 5: Testing Terraform Code](/posts/TestingTerraformCode/)
> - [Part 6: Terraform Modules Deep Dive](/posts/TerraformModulesDeepDive/)
> - **Part 7: CI/CD with GitHub Actions** ← *You are here*

## Building Enterprise-Grade CI/CD Pipelines for Terraform

Welcome to the final of our comprehensive 7-part series on Terraform for PowerShell developers! Throughout this series, we have gone from basic concepts to enterprise-grade infrastructure management. Now, we'll bring everything together by implementing CI/CD pipelines using GitHub Actions.

As PowerShell professionals who've likely worked with Azure DevOps, Jenkins, or other CI/CD tools, you'll find GitHub Actions provides familiar concepts with modern, cloud-native approaches (Even if you have never touched either i believe you are still able to follow along). In this final part, we'll create pipelines to deploy our terraform configuration.

For this i have created the following repo that you can follow along in while we go through this post.

[Terraform CICD](https://github.com/Mynster9361/TerraformCICD){:target="_blank"}

## Prerequicites

1. **App registration**: For us to start creating stuff we need an app registration where we are going to use federated credentials
2. **Azure subscription**: For us to start creating stuff we need access to a subscription for this scenario i have given our app contributor access to my subscription
3. **Github Secrets**: Setup you github secrets
4. **Your config**: In the repo i have included code for applying a resource group and a storage account

### 1. App registration

Create a new App registration call it something that relates to what you are doing or deployment name maybe your github repo name? (What i am trying to say is the name of the app does not matter to me it only matters for you and your organisation standards)

Once created go to **Certificates & secrets** click on **Federated credentials** and **Add credential**

| Option Name                   | Input                                                                                                             |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Federated Credential scenario | GitHub Actions deploying Azure resources                                                                          |
| Issuer                        | https://token.actions.githubusercontent.com                                                                       |
| Organization                  | Your github username or your organisation name                                                                    |
| Repository                    | Name of your github repository                                                                                    |
| Entity type                   | Here i chose Branch as i am just working in the Main branch for my example                                        |
| GitHub branch name            | Here i wrote main as that is the branch i would like to deploy from                                               |
| Subject identifier            | repo:{Organization}/{Repository}:ref:refs/heads/main                                                              |
| Name                          | This is what will be displayed after the federated credtials has been created in the Federated credentials window |
| Description                   | This is what will be displayed after the federated credtials has been created in the Federated credentials window |
| Audience                      | api://AzureADTokenExchange                                                                                        |

Done deal now the federated credential is setup specifically to be able to login from the main branch

### 2. Azure subscription

Now lets give the app some RBAC access on a subscription
Go to a subscription you would like to do something in with terraform go to  **Access control (IAM)** click on **Add** and **Add role assignment** and switch to **Privileged administrator roles** and select **Contributor**.
Click **Next** and **Select members** and search for your app registration created in step 1 click **Select** and click **Review + assign** and click **Review + assign** - *(Yes you have to click it 2 times)*

Done deal now the access is in place next up is our github repo

### 3. Github Secrets

To setup our secrets we will need to gather a bit of data for the implementation i am showing in my example we need the following data:
AZURE_TENANT_ID = *Tenant ID* Your tenant id can easily be found on the Overview page in the **Microsoft Entra ID** blade in Azure
AZURE_CLIENT_ID = Application (client) ID from our app created in step 1
AZURE_SUBSCRIPTION_ID = The subscription ID of the subscription you gave our app access to in step 2

Finally go to your Github repository click on **Settings** click on **Secrets and variables** and **Actions**
In here Click on **New repository secret** and add each secret with the name it like above so
AZURE_TENANT_ID = *Tenant ID*
AZURE_CLIENT_ID = *Application (client) ID*
AZURE_SUBSCRIPTION_ID = *Subscription ID*

Done deal

### 4. Your config

Finally the magic we will create a github action.
This step is quite easy in your repository create a folder called *.github* within that folder create another folder called *workflows*
Then within this folder create a file called *cicd.yml* and paste the following into it:

```yaml
name: Terraform CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest

    permissions:
      id-token: write
      contents: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269862dd # v. 3.1.2 - https://github.com/hashicorp/setup-terraform/commit/b9cd54a3c349d3f38e8881555d616ced269862dd
        with:
          terraform_wrapper: true

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          
      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init -input=false

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Test
        id: terraform-test
        run: |
          terraform test || test_exit_code=$?
          echo "test_exit_code=${test_exit_code:-0}" >> $GITHUB_OUTPUT

      - name: Terraform Plan
        run: terraform plan -input=false -out=tfplan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'   # only auto-apply on main
        run: terraform apply -input=false -auto-approve tfplan
      
      - name: terraform show apply
        if: github.ref == 'refs/heads/main'   # only auto-apply on main
        run: terraform show -no-color

      - name: Terraform Destroy
        if: github.ref == 'refs/heads/main'   # only auto-apply on main
        run: terraform destroy -auto-approve 
```

That is it now we have a complete CICD pipeline so lets end the post here.

**I am just kidding ofcourse lets go over some of the stuff in this flow**

## Lets get into the setup and explain the workflow

### First up we are giving the workflow a name this name is what will be shown in our **Actions** pane in github under *All workflows*

```yaml
name: Terraform CI/CD Pipeline
```

![Action TerrafomrCICD](/assets/img/posts/ActionTerraformCICD.png)

### Second up we have our trigger for our flow
This piece of code basicly says when there is something new added to a branch named **main** it will run this flow and below that we also add a trigger for when someone makes a (PR or pull request) to our repository then it will start this action

```yaml
on:
  push:
    branches:
      - main
  pull_request:
```

### Third we are setting up our actual job
In this code we are saying this is a job - our jobs name is terraform (Name is up to you i like to keep it simple).
Then we are defining what our job will run on so which platform for this i have selected ubuntu-latest.

And finaly we are giving our action some extra permissions to our repository it will get an **id-token write** which it needs for our azure login later and it gets a **contents read** permission so it can read what is in our repository

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest

    permissions:
      id-token: write
      contents: read
```

Next we have the exiting part our Steps thing of it like a stairway you take one step at a time 
So first we checkout our repository with an action made by github

```yaml
    steps:
      - name: Checkout repository
        uses: actions/checkout@v5
```

Then we install terraform using a pre built action made by hashicorp

```yaml
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269862dd # v. 3.1.2 - https://github.com/hashicorp/setup-terraform/commit/b9cd54a3c349d3f38e8881555d616ced269862dd
        with:
          terraform_wrapper: true
```

Then we login to Azure using an action made by Microsoft and suppling our secrets from Github that we setup in prereq 3

```yaml
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

Then we come to the Terraform stuff which makes our whole pipeline
First up we also want to make sure that our terraform code is correctly formated with the `terraform fmt -check` command
next we initialize our terraform code *basicly the same as installing modules before you can run your code* with the command `terraform init -input=false`
Then we validate our configuration with `terraform validate` so we know that every piece of our code is working as it should

Then we run all our tests by default when running `terraform test` it will run all files called *something.tftest.hcl* within a folder called *tests*
Here we are running 2 commands and it is basicly test our terraform code and if it fails outbut the failure to our github action

Then we run `terraform plan` so we get to see what our deployment will look like.

And the last step for us is to apply the plan **BUT** we have an if statement and we are looking at a built in variable called *github.ref* which will return which branch we are in and say that it should only run if the branch we are in is *refs/heads/main*

And finaly since our terraform apply does not output anything other than the creation process we run `terraform show -no-color` to show what has been created

```yaml
      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init -input=false

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Test
        id: terraform-test
        run: |
          terraform test || test_exit_code=$?
          echo "test_exit_code=${test_exit_code:-0}" >> $GITHUB_OUTPUT

      - name: Terraform Plan
        run: terraform plan -input=false -out=tfplan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'   # only auto-apply on main
        run: terraform apply -input=false -auto-approve tfplan
      
      - name: terraform show apply
        if: github.ref == 'refs/heads/main'   # only auto-apply on main
        run: terraform show -no-color
```

Now in my example workflow i also include a destroy at the end just because i have not included any kind of state storage or anything for this CICD workflow so just to cleanup after my self at the end i have added `terraform destroy -auto-approve` which just deletes the newly created resource again

```yaml
      - name: Terraform Destroy
        if: github.ref == 'refs/heads/main'   # only auto-apply on main
        run: terraform destroy -auto-approve 
```

Now if you wanted some kind of backend implementation you could just edit your providers.tf file in my example and add a section like this
*Note it will require you to create the below resource by hand*

```hcl
terraform {
  backend "azurerm" {
    tenant_id            = "Your tenant id"
    subscription_id      = "The subscription id the resources is placed in"
    resource_group_name  = "a resource group with a storage account"
    storage_account_name = "Your state config storage account"
    container_name       = "a container within your storage account"
    key                  = "a primary or secondary key to your storage account the secret can be gotten from Github secrets and injected into the workflow as a variable"
    use_azuread_auth     = true # basicly just for your federated credential authentication
    use_oidc             = true # basicly just for your federated credential authentication
  }
}
```

## Now lets take a closer look at what is in the repo

Our structure looks like this:

*Side not i love that you can get AI to create the below structure output for you so it looks pretty*

```
TerraformCICD/
│
├── .github/
│   └── workflows/
│       └── cicd.yml            # GitHub Actions CI/CD workflow
│
├── modules/
│   └── storage-account/        # Modularized storage account
│       ├── main.tf             # Storage account resource definition
│       ├── outputs.tf          # Module outputs
│       └── variables.tf        # Module input variables
│
├── tests/
│   └── storage_account.tftest.hcl  # Test for storage account module
│
├── .gitignore                  # Git ignore file
├── LICENSE                     # MIT License
├── main.tf                     # Main Terraform configuration
└── providers.tf                # Provider configuration
```

First we have our workflow i will not go deeper into this as we already covered it earlier.

### Module
Then we have a **modules** folder and within this folder we have one called **storage-account**

This is a quick module that i have just copy pasted the config directly from the example of creating an azurerm storage account

Reference: 
[Storage account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account){:target="_blank"}

The only thing i have changed is added the *variables.tf* file and the *outputs.tf* file and then made the inputs more dynamic in the *main.tf*

Just to elaborate all i did was change the static entries to var.variablename

main.tf:
```hcl
resource "azurerm_storage_account" "storage_account" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = var.tags
}
```

Then we have our outputs file which just lets terraform know what you want to be able to reference and see when this module has created the storage account just for reference if you want to see all available outputs you can scroll down to Attributes Reference
[Storage account - Attributes Reference](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#attributes-reference){:target="_blank"}


outputs.tf:
```hcl
output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage_account.name
}

output "id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage_account.id
}
```

Finally the biggest hurdle when doing stuff like this is properly making sure that your variables file is on point as this is where basicly all validation happens to your parameters.

For this section the only validating i have setup is just based on the values that are possible to select so we fail when providing our parameters instead of first failing when trying to run our plan or apply.

variables.tf:
```hcl
variable "name" {
  description = "The name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the storage account"
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account_tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa."
  type        = string

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', or 'RAGZRS'."
  }
}

variable "tags" {
  description = "Tags to assign to the storage account"
  type        = map(string)
  default     = {}
}
```

### Test

Next up we have our test this test is placed in a folder called tests and the file is called **storage_account.tftest.hcl**

This is the test that will run when we run `terraform test` and if there were more those would run aswell
If you need more information on testing take a look at this previous post

[Part 3: Advanced Terraform and PowerShell Integration](/posts/AdvancedTerraformAndPowerShellIntegration/)

```hcl
provider "azurerm" {
  features {}
  subscription_id = "e4495bdf-ae79-4c1c-bebc-101ac07ba353"
}

variables {
  resource_group_name = "rg-test-storage"

  storage_account_name     = "testtfstoraeacct1234"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Development"
    project     = "GetStartedWithTerraform"
    owner       = "Morten"
  }
}

run "create_storage_account" {
  command = apply

  module {
    source = "./modules/storage-account"
  }

  variables {
    resource_group_name      = var.resource_group_name
    location                 = var.location
    name                     = var.storage_account_name
    account_tier             = var.account_tier
    account_replication_type = var.account_replication_type
    tags                     = var.tags
  }

  assert {
    condition     = output.name == var.storage_account_name
    error_message = "Storage account name did not match expected"
  }

}
```

### Our deployment

Finally we have our actual deployment this is what is going to be created when running `terraform apply`

**providers.tf**

```hcl
terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}
```

**main.tf**

```hcl
locals {
  subscription_id = "e4495bdf-ae79-4c1c-bebc-101ac07ba353" # Replace with your Azure Subscription ID

  location = "West Europe"
  rg_name  = "GetStartedWithTerraformPart7"

  storage_account_name             = "terraformpart7"
  storage_account_tier             = "Standard"
  storage_account_replication_type = "LRS"

  common_tags = {
    environment = "Development"
    project     = "GetStartedWithTerraform"
    owner       = "Morten"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = local.location
  tags     = local.common_tags
}

module "storage-account" {
  source                   = "./modules/storage-account"
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = local.storage_account_tier
  account_replication_type = local.storage_account_replication_type
  tags                     = local.common_tags
}
```

In the main file we are first creating a set of local variables needed for doing a fully automated deployment and it is easier to manage all the diffrent names and such when they are at the top and just get referenced further down as long as you give them appropiate name.

Next up we are creating a resource group just using a normal resource block.

And finaly we are using the module that we have created by first writing `module "Some name for this resource" {The config}`

Then we are referencing the path of the module in a `source` parameter *Note that the module could also be in another repository if you wanted to have a collection of all your modules instead of it all being in a single repo* and then just suppling the variables that is defined for that module

And that is it now you have a complete CICD pipeline for deployment.



### The Complete Journey Recap

| Part       | Focus                                                                     | Key PowerShell → Terraform Transitions                   |
| ---------- | ------------------------------------------------------------------------- | -------------------------------------------------------- |
| **Part 1** | [Getting Started](/posts/GettingStartedWithTerraformForPowerShellPeople/) | Imperative scripts → Declarative configuration           |
| **Part 2** | [Resources & State](/posts/ResourcesVariablesAndStateInTerraform/)        | Variables & objects → Terraform variables & data sources |
| **Part 3** | [Advanced Integration](/posts/AdvancedTerraformAndPowerShellIntegration/) | Hybrid workflows → PowerShell + Terraform synergy        |
| **Part 4** | [State & Collaboration](/posts/AdvancedStateManagementAndCollaboration/)  | Team collaboration & remote state                        |
| **Part 5** | [Testing Strategies](/posts/TestingTerraformCode/)                        | Pester testing → Native Terraform testing framework      |
| **Part 6** | [Module Development](/posts/TerraformModulesDeepDive/)                    | PowerShell modules → Terraform modules & composition     |
| **Part 7** | **CI/CD Automation**                                                      | Manual deployments → Automated pipelines & GitOps        |


### Your Enterprise Infrastructure Platform

By combining everything from this series, you now have the knowledge to build a complete infrastructure automation platform.

### Final Thoughts

You've successfully bridged two powerful worlds - the flexibility and familiarity of PowerShell with the declarative power and ecosystem of Terraform. This combination gives you:

- **Best of Both Worlds**: Leverage PowerShell for complex logic while using Terraform for infrastructure management
- **Career Growth**: Infrastructure as Code skills are increasingly valuable in modern IT organizations
- **Future-Proofing**: Position yourself and your organization for cloud-native infrastructure management

The journey from PowerShell scripter/developer to Terraform practitioner represents more than just learning a new tool - it's about embracing modern infrastructure practices that will serve you and your organization for years to come.

Thank you for reading my blog series i really hope that you got some great takeaways from it and that it advances your abilities and your career!
