const express = require("express");
const router = express.Router();

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

/* GET weather forecast raw data. */
router.get("/", (req, res) => {
  const weatherData = generateRandomWeatherData(5);
  res.json(weatherData);
});

module.exports = router;
