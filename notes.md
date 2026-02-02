
### Local Setup
1. Install terraform 
```sh
brew install hashicorp/tap/terraform
```
2-1. Install Azure CLI
```sh
brew update && brew install azure-cli
```
2-2. Install AWs CLI
```sh
brew update && brew install awscli
```
3. Connect to Azure
```sh
az login 
az account list
```
4. Run terraform 
```sh
terraform init
terraform plan
terraform apply
```
5. See terraform output
```sh
terraform output openai_endpoint 
terraform output openai_primary_key
terraform output deployment_name 
```
6. Have the output values paste in the `.env`


#### Case 1: Python call Azure OpenAI and have metrics stored in Azure Monitor
* Run python
```sh
python azure_openai_example.py
```
#### Case 2: Python call Azure OpenAI and have the metrics, logs, and traces in both Azure Monitor and local langfuse
* Run python
```sh
python azure_openai_local_langfuse.py
```



### DevOps in Gitlab