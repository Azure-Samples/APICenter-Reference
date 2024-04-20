namespace ApiApp.Extensions;

/// <summary>
/// This represents the extension entity for <see cref="HttpRequest"/>.
/// </summary>
/// <remarks>
/// Reference: https://blog.elmah.io/how-to-get-base-url-in-asp-net-core/
/// </remarks>
public static class HttpRequestExtensions
{
    /// <summary>
    /// Gets the base URL.
    /// </summary>
    /// <param name="req"><see cref="HttpRequest"/> instance.</param>
    /// <returns>Returns the base URL.</returns>
    public static string? BaseUrl(this HttpRequest req)
    {
        if (req == null) return null;
        var uriBuilder = new UriBuilder(req.Scheme, req.Host.Host, req.Host.Port ?? -1);
        if (uriBuilder.Uri.IsDefaultPort)
        {
            uriBuilder.Port = -1;
        }

        return uriBuilder.Uri.AbsoluteUri;
    }
}