using Microsoft.Kiota.Abstractions.Authentication;
using Microsoft.Kiota.Http.HttpClientLibrary;

using WebApp.ApiClients;

namespace WebApp.Extensions;

/// <summary>
/// This represents the extension entity for <see cref="IServiceCollection"/>.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds the PetStoreClient to the services collection.
    /// </summary>
    /// <param name="services"><see cref="IServiceCollection"/> instance.</param>
    /// <returns>Returns <see cref="IServiceCollection"/> instance.</returns>
    public static IServiceCollection AddPetStoreClient(this IServiceCollection services)
    {
        services.AddScoped<PetStoreClient>(p =>
        {
            var httpClient = p.GetService<HttpClient>();
            httpClient.BaseAddress = new Uri("https://petstore3.swagger.io/api/v3");
            var provider = new AnonymousAuthenticationProvider();
            var adapter = new HttpClientRequestAdapter(provider, httpClient: httpClient);
            adapter.BaseUrl = "https://petstore3.swagger.io/api/v3";
            var client = new PetStoreClient(adapter);

            return client;
        });

        return services;
    }
}
