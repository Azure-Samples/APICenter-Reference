# API Center Reference

Throughout this reference sample, we'd like to give developer experiences how to use API Center (APIC) and seamless integration with API Management (APIM), as well as inner-loop development velocity increase.

- API Inventory
  - To Showcase API Management integration to quickly build API inventory from many API Management instances
  - To register APIs manually or through GitHub Actions workflow
- API Governance
  - To perform shift-left API governance functionality in VS Code
  - To run APIC Analyzer for server-side linting
  - To manage custom metadata
  - To handle events through Azure Event Grid and Logic Apps
- API Discovery and Consumption
  - To integrate the client SDK in .NET & JavaScript
  - To prepare the server app scaffolding in .NET and JavaScript
  - To manage API Center OSS portal

## Prerequisites

- Azure Subscription
- Visual Studio Code with API Center extension
- Azure Developer CLI
- Azure CLI with API Center extension
- GitHub CLI

## Getting Started

1. Fork this repository.
1. Clone the forked repository to your local machine.
1. Login to Azure Developer CLI.

    ```bash
    azd auth login
    ```

1. Provision all resources to Azure and deploy all the apps to those resources.

    ```bash
    azd up
    ```

## Deploy APICenter Analyzer (Optional)

APICenter Analyzer is a tool to lint API specifications on the server-side. If you want to integrate this server-side linting feature, you can install it by following steps.

1. In a separate directory, clone the APICenter Analyzer repository.

    ```bash
    azd init --template Azure/APICenter-Analyzer --branch preview
    ```

1. Provision resources to Azure and deploy the app.

    ```bash
    azd up
    ```

   > You will have to provide the API Center instance name and its resource group name for integration.

## CI/CD Pipelines

As a default, CI/CD pipelines are disabled. To enable CI/CD pipelines, follow these steps.

1. Configure the CI/CD pipeline.

    ```bash
    azd pipeline config
    ```

1. Push your changes to the repository.

## API Registration

You can register APIs to API Center in various ways. But here, we will show you how to register APIs through Azure CLI and the GitHub Actions workflow.

### Azure CLI

#### From local machine

You can register an API to API Center from a local machine, run the following commands:

```bash
# Bash
RESOURCE_GROUP=<RESOURCE_GROUP>
API_DOC_FILE_PATH=<API_DOC_FILE_PATH>
APIC_NAME=<API_CENTER_NAME>

az apic api register -g $RESOURCE_GROUP -s $APIC_NAME --api-location $API_DOC_FILE_PATH

# PowerShell
$RESOURCE_GROUP = "<RESOURCE_GROUP>"
$API_DOC_FILE_PATH = "<API_DOC_FILE_PATH>"
$APIC_NAME = "<API_CENTER_NAME>"

az apic api register -g $RESOURCE_GROUP -s $APIC_NAME --api-location $API_DOC_FILE_PATH
```

> **NOTE**: Replace `<RESOURCE_GROUP>` `<API_DOC_FILE_PATH>` and `<API_CENTER_NAME>` with your values.

#### From API Management

You can also register APIs to API Center directly importing from API Management. Run the following commands:

```bash
# Bash
RESOURCE_GROUP=<RESOURCE_GROUP>
APIC_NAME=<API_CENTER_NAME>
APIM_NAME=<API_MANAGEMENT_NAME>
APIM_ID=$(az resource list --namespace "Microsoft.ApiManagement" --resource-type "service" -g $RESOURCE_GROUP --query "[].id" -o tsv)

az apic service import-from-apim -g $RESOURCE_GROUP -s $APIC_NAME --source-resource-ids "$APIM_ID/apis/*"

# PowerShell
$RESOURCE_GROUP = "<RESOURCE_GROUP>"
$APIC_NAME = "<API_CENTER_NAME>"
$APIM_NAME = "<API_MANAGEMENT_NAME>"
$APIM_ID = az resource list --namespace "Microsoft.ApiManagement" --resource-type "service" -g $RESOURCE_GROUP --query "[].id" -o tsv

az apic service import-from-apim -g $RESOURCE_GROUP -s $APIC_NAME --source-resource-ids "$APIM_ID/apis/*"
```

> **NOTE**: Replace `<RESOURCE_GROUP>` `<APIC_NAME>` and `<APIM_NAME>` with your values.

### GitHub Actions

TBD

## API Center Analyzer

API specifications can be linted using the API Center Analyzer.

### Standalone Linting through Visual Studio Code

TBD

### Server-Side Linting through Azure Portal

TBD

## API Center Portal

TBD

## API Client SDK Integration

TBD

## Resources

- [API Center Documentation](https://aka.ms/apicenter)
- [API Center Analyzer](https://aka.ms/apicenter-analyzer)
- [API Center Portal](https://aka.ms/apicenter-portal)
