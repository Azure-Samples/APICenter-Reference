const port = 3030;

const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

const description = `[http://localhost:${port}/api-docs/swagger.json](http://localhost:${port}/api-docs/swagger.json)`;
const serverUrl = `http://localhost:${port}`;

// Basic swagger definition
const BasicswaggerDefinition = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "webapi",
      description: description,
      version: "1.0.0",
    },
  },
  apis: ["./server.js"],
};

// Improved swagger definition
const ImprovedswaggerDefinition = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Weather Forecast API",
      description: description,
      version: "1.0.0",
      contact: {
        name: "Contoso",
        email: "api@contoso.com",
        url: "https://contoso.com/support",
      },
    },
    servers: [
      {
        url: serverUrl,
      },
    ],
    tags: [
      {
        name: "Weather",
        description: "Weather API",
      },
    ],
  },
  apis: ["./server.js"],
};

const swaggerSpecs = {
  basic: swaggerJsdoc(BasicswaggerDefinition),
  improved: swaggerJsdoc(ImprovedswaggerDefinition),
};

const setupSwaggerUi = (app, specs, path = "/api-docs/swagger") => {
  app.use(path, swaggerUi.serve, swaggerUi.setup(specs));
};

module.exports = {
  swaggerSpecs,
  setupSwaggerUi,
};
