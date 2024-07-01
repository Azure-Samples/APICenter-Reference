const express = require("express");
const { setupSwaggerUi, swaggerSpecs } = require("./routes/openapiservice");
const weatherRouter = require("./routes/weather");

const createError = require("http-errors");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");

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

// view engine setup
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "jade");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use("/weatherforecast", weatherRouter);

app.get("/api-docs/swagger.json", (req, res) => {
  // res.send(swaggerSpecs.improved);
  res.send(swaggerSpecs.basic);
});

// setupSwaggerUi(app, swaggerSpecs.improved, "/api-docs/swagger");
setupSwaggerUi(app, swaggerSpecs.basic, "/api-docs/swagger");

app.get("/", (req, res) => {
  res.redirect("/weatherforecast");
});

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// error handler
app.use(function (err, req, res) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get("env") === "development" ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render("error");
});

module.exports = app;
