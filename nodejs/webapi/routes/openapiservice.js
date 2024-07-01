

const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

// Function to determine if the port value is a named pipe or a port number
function isNamedPipe(port) {
  return isNaN(port);
}

// Function to format the base URL based on the port or named pipe
function formatBaseUrl(port) {
  const host = 'localhost';
  if (isNamedPipe(port)) {
    // Format for named pipe
    return `http://${host}/${port}`;
  } else {
    // Format for port number
    return `http://${host}:${port}`;
  }
}

// Assuming `process.env.PORT` contains your port or named pipe value
const portOrPipe = process.env.PORT || 3030; // Default to 3030 if not set
const baseUrl = formatBaseUrl(portOrPipe);

const environment = process.env.NODE_ENV || "development";

let description, apis;

if (environment === "development") {
  description = `${baseUrl}/api-docs/swagger.json`;
  apis = ["./app.js"];
} else {
  description = "An API that predicts upcoming weather";
  apis = ["../app.js"];
}

// Basic swagger definition
const basicSwaggerDefinition = {
  definition: {
    openapi: "3.0.1",
    info: {
      title: "webapi",
      description: `<a href="${baseUrl}/api-docs/swagger.json" target="_blank">${baseUrl}/api-docs/swagger.json</a>`,
      version: "1.0",
    },
  },
  apis: apis,
};

// Improved swagger definition
const improvedSwaggerDefinition = {
  definition: {
    openapi: "3.0.1",
    info: {
      title: "Weather Forecast API",
      description: description + "<br><br>An API that predicts upcoming weather", 
      version: "v1.0.0",
      contact: {
        name: "Contoso",
        email: "api@contoso.com",
        url: "https://contoso.com/support",
      },
    },
    servers: [
      {
        url: baseUrl,
      },
    ],
    tags: [
      {
        name: "Weather",
        description: "Weather API",
      },
    ],
  },
  apis: apis,
};

const swaggerSpecs = {
  basic: swaggerJsdoc(basicSwaggerDefinition),
  improved: swaggerJsdoc(improvedSwaggerDefinition),
};

const setupSwaggerUi = (app, specs, path = "/api-docs/swagger") => {
  app.use(path, swaggerUi.serve, swaggerUi.setup(specs));
};

module.exports = { setupSwaggerUi, swaggerSpecs };
