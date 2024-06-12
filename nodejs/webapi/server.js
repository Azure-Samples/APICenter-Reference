import express from "express"; // import express
import { swaggerSpecs, setupSwaggerUi } from "./swagger/openapiservice.js";
import { port } from "./config.js";

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

// Random weather data
const generateRandomTemperatureC = () => Math.floor(Math.random() * 61) - 20;
const generateRandomSummary = () =>
  ["Hot", "Warm", "Mild", "Cool", "Bracing", "Scorching", "Freezing"][
    Math.floor(Math.random() * 7)
  ];

// Function to generate random weather data for a specified number of days
const generateRandomWeatherData = (numDays) => {
  const startDate = new Date();
  return Array.from({ length: numDays }, (_, i) => {
    const date = new Date(startDate); // Create a new date instance for each entry
    date.setDate(startDate.getDate() + i);
    const temperatureC = generateRandomTemperatureC();
    const temperatureF = Math.round((temperatureC * 9) / 5 + 32);
    const summary = generateRandomSummary();
    return {
      date: date.toISOString().split("T")[0],
      temperatureC,
      summary,
      temperatureF,
    };
  });
};

// send weather data to /weatherdata
app.get("/weatherforecast", (req, res) => {
  // Generate random weather data for the next 5 days
  const weatherData = generateRandomWeatherData(5);
  res.json(weatherData);
});

app.get("/api-docs/swagger.json", (req, res) => {
  res.send(swaggerSpecs.basic);
});

setupSwaggerUi(app, swaggerSpecs.basic, "/api-docs/swagger");

app.get("/", (req, res) => {
  res.redirect("/api-docs/swagger");
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
