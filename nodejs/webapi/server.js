const express = require('express'); // import express
bodyParser = require('body-parser'); // import body-parser to parse JSON content
swaggerJSDoc = require('swagger-jsdoc'); // import swagger-jsdoc to generate swagger doc
swaggerUi = require('swagger-ui-express'); // import swagger-ui-express to serve swagger docs
const openapi = require('@wesleytodd/openapi'); // import openapi to create openapi spec from json
const fs = require('fs'); // import fs to read file    
const path = require('path') // import path to resolve path

// TODO
const swaggerSpec = require('./swagger/weatherforecast.json')
// const swaggerSpec = require('./swagger/weatherforecast-reviewed.json')

const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// TODO
const openapiFilePath = path.resolve(__dirname, 'swagger', 'weatherforecast.json');
// const openapiFilePath = path.resolve(__dirname, 'swagger', 'weatherforecast-reviewed.json');

const openapiFileContent = fs.readFileSync(openapiFilePath, 'utf8');
const openapiSpec = JSON.parse(openapiFileContent);

const oapi = openapi(openapiSpec);

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
    res.send(weatherdata);
});

// set redirect to /weatherdata
app.get('/', (req, res) => {
    res.redirect('/weatherdata');
});

app.use('/weatherdata', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.use('/swagger/v1', oapi);

const port = process.env.PORT || 5051;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}
);


