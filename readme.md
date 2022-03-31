# Marketplace Notifications Webhook

This repo contains a simple solution for sinking Azure managed application notification events. It consisits of:

* A static web app which acts as a simple proxy to receive and check the notification is valid
* A Logic App workflow to gather the deployment details and invoke a GitHub action

The proxy is necessary because the notification URL format is fixed so some sort of routing capability is required. Instead of static web apps you could use:

* Azure Function + proxies
* Azure API Management

Only the routing capability and API (Azure function) of the static web app is being used.

## Static Web App

There is a single function at ```api/notification-webhook``` which checks the webook signature query parameter matches the expected value. If it does, it accepts the request. If the notification is for a new, successful deployment, it will call the Logic App workflow to invoke a GitHub actions workflow to complete the post deployment steps (typically deploying an application).

### Application Settings

* ```GITHUB_WORKFLOW_DISPTACH_URI``` - the URI for the GitHub actions workflow
* ```SIGNATURE_GUID``` - the expected signature parameter value for the webhook call
* ```WORKFLOW_URI``` - the URI for the deployed Logic Apps workflow

## Logic App

The Logic App workflow parses the payload from the webhook and queries the ARM API for details of the deployment. It retrieves a GitHub personal access token (PAT) from Key Vault and uses this to authenticate to GitHub. The final step is a call to the dispatch URI to invoke the GitHub workflow.

### Dependencies

* API Connections
  * The Logic App requires two API connections. One for Azure Resource Manager (Service Principal) and one for Azure Key Vault (Managed Identity)
* Key Vault
  * A Key Vault to store the GitHub PAT. Use Managed Identity and RBAC on the Key Vault to grant access to the secrets.
