const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

// Basic swagger definition
const BasicswaggerDefinition = {
    definition: {
        openapi: "3.0.0",
        info: {
         title: "ApiApp",
         description: "[http://localhost:5051/swagger-basic.json](http://localhost:5051/swagger-basic.json)",
         version: "1.0.0"
        },
    },
    apis: ['./server.js'],
};

// Improved swagger definition
const ImprovedswaggerDefinition = {
    definition: {
        openapi: "3.0.0",
        info: {
         title: "Weather Forecast API",
         description: "[http://localhost:5051/swagger-improved.json](http://localhost:5051/swagger-improved.json)",
         version: "1.0.0",
         contact: {
            name: 'Contoso',
            email: 'api@contoso.com',
            url: 'https://contoso.com/support',
         },
        },
        servers: [
           {
            url: 'http://localhost:5051',
           },
        ],
        tags: [
           {
            name: 'Weather',
            description: 'Weather API',
           },
        ],
    },
    apis: ['./server.js'],
  };

const swaggerSpecs = {
  basic: swaggerJsdoc(BasicswaggerDefinition),
  improved: swaggerJsdoc(ImprovedswaggerDefinition),
};

const setupSwaggerUi = (app, specs, path = '/api-docs') => {
  app.use(path, swaggerUi.serve, swaggerUi.setup(specs));
};

module.exports = {
  swaggerSpecs,
  setupSwaggerUi,
};
