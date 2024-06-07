<!-- markdownlint-disable MD033 -->
# API Center Analyzer Integration

You can analyze your API documents using Visual Studio Code (Standalone) or Azure Portal (Server-Side). This section will guide you through the integration process.

## Standalone Analyzer through Visual Studio Code

> To use this standalone analyzer, you need to install the [API Center extension](https://marketplace.visualstudio.com/items?itemName=apidev.azure-api-center) in Visual Studio Code.

1. Run the sample app.

    ```javascript
    cd nodejs/webapi && npm start
    ```

   You'll see the following Swagger UI page.

   ![Swagger UI - weather forecast](./images/api-center-analyzer-integration-nodejs-01.png)

1. Navigate to http://localhost:3000/api-docs/swagger.json to see the OpenAPI document.

   ![OpenAPI - weather forecast](./images/api-center-analyzer-integration-nodejs-02.png)

1. Save the OpenAPI document to `weatherforecast.json`.
1. Stop the sample app by pressing <kbd>Ctrl</kbd>+<kbd>C</kbd>.
1. Open `weatherforecast.json` in Visual Studio Code. You'll see many yellow lines and red lines

   ![OpenAPI - standalone analysis](./images/api-center-analyzer-integration-nodejs-03.png)

1. Type <kbd>F1</kbd> then select "Azure API Center: Set active API Style Guide".

   ![Standalone API Analysis](./images/api-center-analyzer-integration-04.png)

   You will have several options to choose the styles. Choose either `Microsoft Azure REST API` or `OWASP API Security Top 10` and see the analysis results.

   ![Standalone API Analysis - Choose style](./images/api-center-analyzer-integration-05.png)

1. You can also choose the custom API style guide that reflects your organization's policies. This time choose `Select Local File` then select the `resources/rulesets/oas.yaml` file. You'll still see many yellow lines and red lines. Hover your mouse and see what needs to be fixed.

   ![Standalone API Analysis - analysis result](./images/api-center-analyzer-integration-06.png)


1. Open `nodejs/webapi/server.js`, find the following code block and comment it out

    ```javascript
    // route to serve basic swagger JSON, Set up Swagger UI and redirect
    app.get('/api-docs/swagger.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpecs.basic);
    });
    
    setupSwaggerUi(app, swaggerSpecs.basic, '/weatherforecast');
    
    app.get('/', (req, res) => {
      res.redirect('/weatherforecast');
    });
    ```

1. Find the following code block and uncomment it:

    ```javascript
    // route to serve improved swagger JSON, Set up Swagger UI and redirect
    app.get('/api-docs/swagger.json', (req, res) => {
      res.setHeader('Content-Type', 'application/json');
      res.send(swaggerSpecs.improved);
    });
    
    setupSwaggerUi(app, swaggerSpecs.improved, '/weatherforecast');
    
    app.get('/', (req, res) => {
      res.redirect('/weatherforecast');
    });
    ```


1. Run the sample app again. Ensure you are still in `nodejs/webapi`

    ```javascript
    npm start
    ```

   You'll see the following Swagger UI page.

   ![Swagger UI - weather forecast reviewed](./images/api-center-analyzer-integration-nodejs-07.png)

1. Navigate to http://localhost:3000/api-docs/swagger.json to see the OpenAPI document.

   ![OpenAPI - weather forecast reviewed](./images/api-center-analyzer-integration-nodejs-08.png)

1. Save the OpenAPI document to `weatherforecast-reviewed.json`.
1. Stop the sample app by pressing <kbd>Ctrl</kbd>+<kbd>C</kbd>.
1. Open `weatherforecast-reviewed.json` in Visual Studio Code. You'll see all yellow lines and red lines disappeared.

   ![Standalone API Analysis - reviewed analysis result](./images/api-center-analyzer-integration-nodejs-09.png)

## Server-Side Analyzer through Azure Portal

To use this server-side analysis feature, you need to install the [APICenter Analyzer](https://github.com/Azure/APICenter-Analyzer) first.

### Install APICenter Analyzer

[APICenter Analyzer](https://github.com/Azure/APICenter-Analyzer) is a tool to analyze API specifications on the server-side. If you want to integrate this server-side analysis feature, you can install it by following steps.

1. In a separate directory, say `~/apic-analyzer`, clone the APICenter Analyzer repository.

    ```bash
    azd init --template Azure/APICenter-Analyzer --branch preview
    ```

   > You will be asked to provide the environment name. Give it a different name from the one holding the existing API Center.

1. Copy over the ruleset to the APICenter Analyzer repository.

    ```bash
    # Bash
    cp resources/rulesets/oas.yaml ~/apic-analyzer/resources/rulesets/

    # PowerShell
    Copy-Item -Path resources/rulesets/oas.yaml -Destination ~/apic-analyzer/resources/rulesets/
    ```

1. Provision resources to Azure and deploy the app.

    ```bash
    azd up
    ```

   > You will have to provide the existing API Center instance name and its resource group name for integration.

### Server-Side Analysis by Registering API

1. Register `weatherforecast.json` to API Center through Azure Portal or through this document, [API Registration](./api-registration.md).
1. Check the warnings and errors in the API Center.

   ![Server-Side API Analysis](./images/api-center-analyzer-integration-10.png)

1. Update existing API definition with `weatherforecast-reviewed.json` to API Center through Azure Portal or through this document, [API Registration](./api-registration.md).
1. Check the warnings and errors in the API Center.

   ![Server-Side API Analysis - reviewed](./images/api-center-analyzer-integration-11.png)
