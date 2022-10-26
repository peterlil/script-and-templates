using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.Resource;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using obo_api_client;
using Azure.Core;
using Microsoft.Identity.Client;

namespace obo_api_client.Controllers;

[Authorize]
[ApiController]
[Route("[controller]")]
[RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;
    readonly ITokenAcquisition _tokenAcquisition;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public WeatherForecastController(ILogger<WeatherForecastController> logger,
        IConfiguration configuration,
        ITokenAcquisition tokenAcquisition,
        IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _configuration = configuration;
        _tokenAcquisition = tokenAcquisition;
        _httpClientFactory = httpClientFactory;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        var client = _httpClientFactory.CreateClient();
        var scope = _configuration["obo-api-server-sample:Scopes"];
        string accessToken = string.Empty;

        try
        {
            accessToken = _tokenAcquisition.GetAccessTokenForUserAsync(new[] { scope }).Result; // Must have client secret to call an api
        }
        catch (MicrosoftIdentityWebChallengeUserException ex)
        {
            _tokenAcquisition.ReplyForbiddenWithWwwAuthenticateHeader(new[] { scope }, ex.MsalUiRequiredException);
            return new List<WeatherForecast>();
        }
        catch (MsalUiRequiredException ex)
        {
            _tokenAcquisition.ReplyForbiddenWithWwwAuthenticateHeader(new[] { scope }, ex);
            return new List<WeatherForecast>();
        }


        client.BaseAddress = new Uri(_configuration["obo-api-server-sample:ApiBaseAddress"]);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        var response = client.GetAsync("weatherforecast").Result;
        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content.ReadAsStringAsync().Result;
            var weatherForecast = JsonSerializer.Deserialize<List<WeatherForecast>>(responseContent);
            
            return weatherForecast;
        }

        throw new ApplicationException($"Status code: {response.StatusCode}, Error: {response.ReasonPhrase}");
    }
}
