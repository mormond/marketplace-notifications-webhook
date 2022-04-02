# Marketplace Notifications Webhook

## Overview

This repo contains a simple solution for sinking Azure managed application notification events. It consists of:

* A **Static Web App** which acts as a simple proxy to receive and check the notification is valid
* A **Logic App** workflow to gather the deployment details and invoke a GitHub action

The proxy is necessary because the notification URL format is fixed - some sort of routing capability is required. Instead of static web apps you could use:

* Azure Function + proxies
* Azure API Management

Only the routing capability and API (Azure function) of the static web app is being used.

## Services Deployed

### Static Web App

There is a single function at ```api/notification-webhook``` which checks the webook signature (```?sig=xxx```) query parameter matches the expected value. If it does, it accepts the request.

If the notification is for a new, successful deployment, it calls the Logic App workflow. This worklow invokes a GitHub actions workflow to complete the post deployment steps (typically deploying an application).

#### Static Web App Dependencies

The following **Application Settings** are required:

* ```GITHUB_WORKFLOW_DISPTACH_URI``` - the URI for the GitHub actions workflow
* ```SIGNATURE_GUID``` - the expected signature parameter value for the webhook call
* ```WORKFLOW_URI``` - the URI for the deployed Logic Apps workflow

### Logic App

The Logic App workflow parses the payload from the webhook and queries the ARM API for details of the deployment. It retrieves a GitHub personal access token (PAT) from Key Vault and uses this to authenticate to GitHub. The final step is a call to the dispatch URI to invoke the GitHub workflow.

#### Logic App Dependencies

* API Connections
  * The Logic App requires two API connections
    * One for Azure Resource Manager (suggest to use a Service Principal)
    * One for Azure Key Vault (suggest to use Managed Identity)
* Key Vault
  * To store the GitHub PAT
  * Use RBAC on the Key Vault to grant access to the Logic App managed identity to access the secrets.

## Deployment Steps

### Deploy Static Web App

* Create your own copy of this repo
* Create a new Static Web App in the Azure Portal
* Complete the details and connect to your GH repo
* In the **Build Details** section
  * Set **Build Presets** to ```Custom```
  * Set **App location** to ```src```
  * Set **Api location** to ```api```
* Review + create
* Set the **Application Settings** per the dependencies section above

### Deploy Logic App

* Create the Logic App using the ARM template ```logic-app/mainTemplate.json```
* You can either deploy with the CLI or [deploy via the Azure Portal](https://portal.azure.com/#create/Microsoft.Template)

### Create a Key Vault to store the GH secret

* Create a Key Vault resource and configure it for RBAC access
* Grant ```Key Vault Secrets User``` access to the managed identity of your Logic App
  * You can grant the role assignment in the Azure Portal
    * Navigate to your Logic App
    * Naviagte to Settings -> Identity
    * Click on **Azure role assignments**

### Fix Connections

* You will need to fix up the Logic App connections
* It's probably simplest to recreate the connections in the designer