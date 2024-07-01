const port = process.env.PORT || 3030;
const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

const description = `[http://localhost:${port}/api-docs/swagger.json](http://localhost:${port}/api-docs/swagger.json)`;
const serverUrl = `http://localhost:${port}`;

// Basic swagger definition
const basicSwaggerDefinition = {
  definition: {
    openapi: "3.0.1",
    info: {
      title: "webapi",
      description: description,
      version: "1.0",
    },
  },
  apis: ["../app.js"],
};

// Improved swagger definition
const improvedSwaggerDefinition = {
  definition: {
    openapi: "3.0.1",
    info: {
      title: "Weather Forecast API",
      description: description,
      version: "v1.0.0",
      contact: {
        name: "Contoso",
        email: "api@contoso.com",
        url: "https://contoso.com/support",
      },
    },
    servers: [
      {
        url: serverUrl,
        tags: [
          {
            name: "Weather",
            description: "Weather API",
          },
        ],
      },
    ],
  },
  apis: ["../app.js"],
};

const swaggerSpecs = {
  basic: swaggerJsdoc(basicSwaggerDefinition),
  improved: swaggerJsdoc(improvedSwaggerDefinition),
};

const setupSwaggerUi = (app, specs, path = "/api-docs/swagger") => {
  app.use(path, swaggerUi.serve, swaggerUi.setup(specs));
};

module.exports = { setupSwaggerUi, swaggerSpecs };
