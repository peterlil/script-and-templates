// https://damienbod.com/2020/11/09/implement-a-web-app-and-an-asp-net-core-secure-api-using-azure-ad-which-delegates-to-second-api/

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Net.Http.Headers;
using Microsoft.Identity.Web;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace obo_web_client.Pages;

[Authorize]
public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    readonly ITokenAcquisition _tokenAcquisition;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public IndexModel(ILogger<IndexModel> logger,
        IConfiguration configuration,
        ITokenAcquisition tokenAcquisition,
        IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _configuration = configuration;
        _tokenAcquisition = tokenAcquisition;
        _httpClientFactory = httpClientFactory;
    }

    public void OnGet()
    {

        var client = _httpClientFactory.CreateClient();
        string scope = _configuration["obo-api-client-sample:Scopes"];
        var accessToken = _tokenAcquisition.GetAccessTokenForUserAsync(new[] { scope }).Result; // Must have client secret to call an api

        client.BaseAddress = new Uri(_configuration["obo-api-client-sample:ApiBaseAddress"]);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        var response = client.GetAsync("weatherforecast").Result;
        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content.ReadAsStringAsync().Result;
            var weatherForecast = JsonSerializer.Deserialize<List<TemperatureSample>>(responseContent);
            ViewData["WeatherForecast"] = weatherForecast;
            return;
        }

        throw new ApplicationException($"Status code: {response.StatusCode}, Error: {response.ReasonPhrase}");
    }

}

