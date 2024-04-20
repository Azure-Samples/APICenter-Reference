using ApiApp.Filters;

using Microsoft.OpenApi.Models;

namespace ApiApp.Extensions;

/// <summary>
/// This represents the extension entity for <see cref="IServiceCollection"/>.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds the OpenAPI service.
    /// </summary>
    /// <param name="services"><see cref="IServiceCollection"/> instance.</param>
    /// <returns>Returns <see cref="IServiceCollection"/> instance.</returns>
    public static IServiceCollection AddOpenApiService(this IServiceCollection services)
    {
        // Add services to the container.

        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen();

        return services;
    }

    /// <summary>
    /// Adds the enriched OpenAPI service.
    /// </summary>
    /// <param name="services"><see cref="IServiceCollection"/> instance.</param>
    /// <returns>Returns <see cref="IServiceCollection"/> instance.</returns>
    public static IServiceCollection AddImprovedOpenApiService(this IServiceCollection services)
    {
        // Add services to the container.
        services.AddHttpContextAccessor();

        // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(options =>
        {
            var info = new OpenApiInfo()
            {
                Version = Constants.Version,
                Title = "Weather Forecast API",
                Description = "An API that predicts upcoming weather",
                Contact = new OpenApiContact
                {
                    Name = "Contoso",
                    Email = "api@contoso.com",
                    Url = new Uri("https://contoso.com/support"),
                },
            };
            options.SwaggerDoc(Constants.Version, info);
            options.DocumentFilter<OpenApiTagFilter>();

            var accessor = services.BuildServiceProvider().GetService<IHttpContextAccessor>();
            var request = accessor.HttpContext.Request;
            var server = new OpenApiServer
            {
                Url = $"{request.BaseUrl().TrimEnd('/')}/api",
            };
            options.AddServer(server);
        });

        return services;
    }
}
