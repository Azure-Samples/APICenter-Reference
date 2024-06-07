const express = require('express'); // import express
swaggerJSDoc = require('swagger-jsdoc'); // import swagger-jsdoc to generate swagger doc
swaggerUi = require('swagger-ui-express'); // import swagger-ui-express to serve swagger docs
const { swaggerSpecs, setupSwaggerUi } = require('./swagger/openapiservice');

// JSDoc comments for api endpoints
/**
 * @swagger
 * /weatherdata:
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

// send weather data to /weatherdata
app.get('/weatherdata', (req, res) => {
    res.json(weatherdata);
});

// route to serve basic swagger JSON, Set up Swagger UI and redirect
app.get('/api-docs/swagger.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpecs.basic);
});

setupSwaggerUi(app, swaggerSpecs.basic, '/weatherforecast');

app.get('/', (req, res) => {
  res.redirect('/weatherforecast');
});

// // route to serve improved swagger JSON, Set up Swagger UI and redirect
// app.get('/api-docs/swagger.json', (req, res) => {
//   res.setHeader('Content-Type', 'application/json');
//   res.send(swaggerSpecs.improved);
// });

// setupSwaggerUi(app, swaggerSpecs.improved, '/weatherforecast');

// app.get('/', (req, res) => {
//   res.redirect('/weatherforecast');
// });

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}
);


