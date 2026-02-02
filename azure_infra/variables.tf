variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-openai-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"  # Change based on model availability in your region
  
  # Note: Not all regions support all models
  # Check availability: https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models
}

variable "openai_service_name" {
  description = "Name of the Azure OpenAI service (must be globally unique)"
  type        = string
  default     = "openai-demo-service"  # Change this to something unique
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID where resources will be created"
  type        = string
}
