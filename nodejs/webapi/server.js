const express = require('express'); // import express
swaggerJSDoc = require('swagger-jsdoc'); // import swagger-jsdoc to generate swagger doc
swaggerUi = require('swagger-ui-express'); // import swagger-ui-express to serve swagger docs
const { swaggerSpecs, setupSwaggerUi } = require('./swagger/openapiservice');

// JSDoc comments for api endpoints
/**
 * @swagger
 * /weatherforecast:
 *   get:
 *    description: Use to request weather data
 *    operationId: getWeatherData
 *    tags:
 *    - Weather
 *    responses:
 *     200:
 *      description: A successful response
 *      content:
 *       application/json:
 *        schema:
 *         type: array
 *         items:
 *          type: object
 *          properties:
 *           date:
 *            type: string
 *            format: date
 *            description: Date of the weather forecast
 *            example: '2024-06-05'
 *           temperatureC:
 *            type: integer
 *            description: Temperature in Celsius
 *            example: 51
 *           summary:
 *            type: string
 *            description: Weather summary
 *            example: Cool
 *           temperatureF:
 *            type: integer
 *            description: Temperature in Fahrenheit
 *            example: 123
*/

const app = express();

// sample weather data
const weatherdata = [
  {
    "date": "2024-06-05",
    "temperatureC": 51,
    "summary": "Cool",
    "temperatureF": 123
  },
  {
    "date": "2024-06-06",
    "temperatureC": 28,
    "summary": "Mild",
    "temperatureF": 82
  },
  {
    "date": "2024-06-07",
    "temperatureC": 17,
    "summary": "Bracing",
    "temperatureF": 62
  },
  {
    "date": "2024-06-08",
    "temperatureC": 14,
    "summary": "Scorching",
    "temperatureF": 57
  },
  {
    "date": "2024-06-09",
    "temperatureC": 14,
    "summary": "Cool",
    "temperatureF": 57
  }
]

// send weather data to /weatherforecast 
app.get('/weatherforecast', (req, res) => {
    res.json(weatherdata);
});

// route to serve basic swagger JSON, Set up Swagger UI and redirect
app.get('/swagger-basic.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpecs.basic);
});

setupSwaggerUi(app, swaggerSpecs.basic, '/api-docs/basic');

app.get('/', (req, res) => {
  res.redirect('/api-docs/basic');
});

// // route to serve improved swagger JSON, Set up Swagger UI and redirect
// app.get('/swagger-improved.json', (req, res) => {
//   res.setHeader('Content-Type', 'application/json');
//   res.send(swaggerSpecs.improved);
// });

// setupSwaggerUi(app, swaggerSpecs.improved, '/api-docs/improved');

// app.get('/', (req, res) => {
//   res.redirect('/api-docs/improved');
// });

const port = process.env.PORT || 5051;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}
);


