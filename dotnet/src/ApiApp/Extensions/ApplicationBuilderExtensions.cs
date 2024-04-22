namespace ApiApp.Extensions;

/// <summary>
/// This represents the extension entity for <see cref="IApplicationBuilder"/>.
/// </summary>
public static class ApplicationBuilderExtensions
{
    /// <summary>
    /// Adds the weather forecast endpoint.
    /// </summary>
    /// <param name="app"><see cref="WebApplication"/> instance.</param>
    /// <param name="summaries">List of weather forecast summaries.</param>
    /// <returns>Returns <see cref="IApplicationBuilder"/>.</returns>
    public static IApplicationBuilder UseWeatherForecastEndpoint(this WebApplication app, string[] summaries)
    {
        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        app.UseHttpsRedirection();

        app.MapGet("/", () =>
        {
            return Results.Redirect("/weatherforecast");
        })
        .ExcludeFromDescription();

        app.MapGet("/weatherforecast", () =>
        {
            var forecast = Enumerable.Range(1, 5).Select(index =>
                new WeatherForecast
                (
                    DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                    Random.Shared.Next(-20, 55),
                    summaries[Random.Shared.Next(summaries.Length)]
                ))
                .ToArray();
            return forecast;
        })
        .WithName("GetWeatherForecast")
        .WithOpenApi();

        return app;
    }

    /// <summary>
    /// Adds the OpenAPI-enriched weather forecast endpoint.
    /// </summary>
    /// <param name="app"><see cref="WebApplication"/> instance.</param>
    /// <param name="summaries">List of weather forecast summaries.</param>
    /// <returns>Returns <see cref="IApplicationBuilder"/>.</returns>
    public static IApplicationBuilder UseImprovedWeatherForecastEndpoint(this WebApplication app, string[] summaries)
    {
        app.UsePathBase(new PathString("/api"));
        app.UseRouting();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI(options =>
            {
                options.SwaggerEndpoint($"{Constants.Version}/swagger.json", "Weather Forecast API");
            });
        }

        app.UseHttpsRedirection();

        app.MapGet("/", () =>
        {
            return Results.Redirect("/weatherforecast");
        })
        .ExcludeFromDescription();

        app.MapGet("/weatherforecast", () =>
        {
            var forecast = Enumerable.Range(1, 5).Select(index =>
                new WeatherForecast
                (
                    DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                    Random.Shared.Next(-20, 55),
                    summaries[Random.Shared.Next(summaries.Length)]
                ))
                .ToArray();
            return forecast;
        })
        .WithTags("weather")
        .WithName("GetWeatherForecast")
        .WithOpenApi(operation =>
        {
            operation.Summary = "Get the weather forecast";
            operation.Description = "Returns the weather forecast for the next five days.";

            return operation;
        });

        return app;
    }
}
