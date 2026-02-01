output "openai_endpoint" {
  description = "Azure OpenAI endpoint URL"
  value       = azurerm_cognitive_account.openai.endpoint
  sensitive   = false
}

output "openai_primary_key" {
  description = "Primary access key for Azure OpenAI"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "openai_service_name" {
  description = "Name of the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.name
}

output "deployment_name" {
  description = "Name of the GPT model deployment"
  value       = azurerm_cognitive_deployment.gpt5_mini.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.openai_rg.name
}
