import { port } from "../config.js";

import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";

const description = `[http://localhost:${port}/api-docs/swagger.json](http://localhost:${port}/api-docs/swagger.json)`;
const serverUrl = `http://localhost:${port}`;

// Basic swagger definition
const BasicswaggerDefinition = {
  definition: {
    openapi: "3.0.1",
    info: {
      title: "webapi",
      description: description,
      version: "1.0",
    },
  },
  apis: ["./server.js"],
};

// Improved swagger definition
const ImprovedswaggerDefinition = {
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

export { setupSwaggerUi, swaggerSpecs };
