# Azure OpenAI with Terraform - Setup Guide

This project provisions Azure OpenAI resources using Terraform and includes a Python example for calling the API.

## Prerequisites

1. **Azure Subscription** with Azure OpenAI access
   - You need to apply for access: https://aka.ms/oai/access
   - Approval typically takes a few business days

2. **Azure CLI** installed and authenticated
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

3. **Terraform** installed (version 1.0+)
   - Download from: https://www.terraform.io/downloads

4. **Python 3.8+** for running the example

## Step 1: Provision Azure Resources with Terraform

1. **Customize variables** (optional):
   Edit `variables.tf` to change:
   - Resource group name
   - Azure region (check model availability for your region)
   - OpenAI service name (must be globally unique)

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

5. **Get the outputs** (you'll need these for Python):
   ```bash
   terraform output openai_endpoint
   terraform output openai_primary_key
   terraform output deployment_name
   ```

## Step 2: Set Up Python Environment

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your values from Terraform outputs:
   ```
   AZURE_OPENAI_ENDPOINT=https://your-service.openai.azure.com/
   AZURE_OPENAI_KEY=your-key-from-terraform-output
   AZURE_OPENAI_DEPLOYMENT=gpt-4o-mini
   ```

3. **Run the example**:
   ```bash
   python azure_openai_example.py
   ```

## What's Provisioned

- **Resource Group**: Container for all resources
- **Azure OpenAI Service**: Cognitive Services account with OpenAI kind
- **Model Deployment**: GPT-4o-mini deployment with 10K TPM capacity

## Important Notes

### Model Availability
- Not all models are available in all regions
- Check current availability: https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models
- GPT-4o-mini is generally more widely available than GPT-4

### Cost Considerations
- Azure OpenAI charges per token
- GPT-4o-mini: ~$0.15 per 1M input tokens, ~$0.60 per 1M output tokens
- GPT-4: Significantly more expensive (~$30 per 1M input tokens)
- The S0 SKU has no fixed monthly cost, only usage-based pricing

### Capacity (TPM)
- TPM = Tokens Per Minute
- Default deployment: 10K TPM (10,000 tokens/minute)
- Adjust in `main.tf` under `sku.capacity` if you need more

### Security
- **Never commit `.env` file** to version control
- Consider using Azure Key Vault for production
- The Terraform state contains sensitive data - store it securely
- Use managed identities instead of API keys in production

## Clean Up

To destroy all resources and avoid charges:
```bash
terraform destroy
```

## Troubleshooting

### "Model not available in region"
- Change `location` in `variables.tf` to a supported region
- Check model availability documentation

### "Deployment creation failed"
- Ensure you have Azure OpenAI access approved
- Verify the model version is correct
- Check capacity quotas in your subscription

### Python script errors
- Verify environment variables are set correctly
- Check that the deployment is fully created (can take a few minutes)
- Ensure the API version in Python matches what's supported

## Next Steps

- Explore different models (GPT-4, embeddings, etc.)
- Implement error handling and retry logic
- Add content filtering configuration
- Set up monitoring and logging
- Implement rate limiting in your application

## References

- [Azure OpenAI Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [OpenAI Python Library](https://github.com/openai/openai-python)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
