Terraform Infrastructure for Azure Services

Overview

This Terraform configuration sets up various Azure resources including:

Azure MySQL Flexible Server with private networking.

Azure Key Vault to store sensitive credentials securely.

Private DNS Zone for name resolution.

Private Endpoint for secure database access.

Azure Container Registry (ACR) for container image storage.

Environment-based deployment, using the Git branch name as the environment reference.

Separate secrets per environment for security.


Setup Instructions

1️⃣ Prerequisites

Ensure you have the following installed:

Terraform

Azure CLI

Proper Azure permissions to create resources

2️⃣ Clone the Repository

git clone https://github.com/your-repo.git
cd your-repo

3️⃣ Set Up Environment Variables

This setup uses the Git branch name as the environment reference. Each environment has its own secrets stored in Azure Key Vault.

To switch environments:

git checkout dev  # Example: Switch to dev environment
export TF_VAR_environment=dev  # Set the Terraform environment variable

4️⃣ Initialize Terraform

terraform init

5️⃣ Plan the Deployment

terraform plan -var="environment=$(git rev-parse --abbrev-ref HEAD)"

6️⃣ Apply the Configuration

terraform apply -var="environment=$(git rev-parse --abbrev-ref HEAD)" -auto-approve

7️⃣ Retrieve the Database Password

The database password is securely stored in Azure Key Vault. Retrieve it using:

az keyvault secret show --name sqlpassword --vault-name jti-$(git rev-parse --abbrev-ref HEAD)-vault --query value -o tsv

Resources Created

🔹 Key Vault (azurerm_key_vault)

Stores sensitive data like the MySQL admin password.

🔹 MySQL Flexible Server (azurerm_mysql_flexible_server)

Creates a MySQL database with private access.

Password is pulled from Key Vault.

🔹 Private DNS Zone (azurerm_private_dns_zone)

Resolves MySQL Private Endpoint inside the Virtual Network.

🔹 Private Endpoint (azurerm_private_endpoint)

Provides a secure, private connection to MySQL.

🔹 Azure Container Registry (ACR) (azurerm_container_registry)

Creates a private container registry for storing Docker images.

The registry name is environment-specific: jti${var.environment}acr.

Admin access is disabled for security.

Uses the Basic SKU for cost efficiency.

Managing Terraform State

Since this project supports multiple environments, you should use Terraform remote backend (e.g., Azure Storage) to store the Terraform state securely.

Destroying the Infrastructure

To remove all resources:

terraform destroy -var="environment=$(git rev-parse --abbrev-ref HEAD)" -auto-approve

Conclusion

This Terraform configuration provides a secure, environment-based deployment of Azure services, including MySQL Flexible Server, Key Vault, Private Networking, and Container Registry.

For any issues, check Azure logs or run:

tf plan -debug

