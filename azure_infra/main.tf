terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# Resource Group
resource "azurerm_resource_group" "openai_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_service_name
  location            = azurerm_resource_group.openai_rg.location
  resource_group_name = azurerm_resource_group.openai_rg.name
  kind                = "OpenAI"
  sku_name            = "S0"

  # Network and security settings
  public_network_access_enabled = true
  
  tags = {
    environment = "development"
    managed_by  = "terraform"
  }
}

# Model Deployment - GPT-4o mini (more cost-effective for testing)
resource "azurerm_cognitive_deployment" "gpt5_mini" {
  name                 = "gpt-5-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-5-mini"
    version = "2025-08-07"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 10  # TPM in thousands (10K tokens per minute)
  }
}
