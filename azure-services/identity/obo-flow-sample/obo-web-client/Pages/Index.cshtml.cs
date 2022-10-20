// https://damienbod.com/2020/11/09/implement-a-web-app-and-an-asp-net-core-secure-api-using-azure-ad-which-delegates-to-second-api/

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Net.Http.Headers;
using Microsoft.Identity.Web;
using System.Net.Http.Headers;

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
        var scope = _configuration["obo-api-server-sample:UseApi"];
        var accessToken = _tokenAcquisition.GetAccessTokenForUserAsync(new[] { scope }).Result; // Must have client secret to call an api

        client.BaseAddress = new Uri(_configuration["obo-api-server-sample:ApiBaseAddress"]);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        var response = client.GetAsync("weatherforecast").Result;
        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content.ReadAsStringAsync().Result;
            return;
        }

        throw new ApplicationException($"Status code: {response.StatusCode}, Error: {response.ReasonPhrase}");
        // var request = new HttpRequestMessage(
        //     HttpMethod.Get,
        //     "https://localhost:7090/WeatherForecast")
        // {
        //     Headers =
        //     {
        //         { HeaderNames.UserAgent, "HttpRequestsSample" },
        //         { HeaderNames.Authorization, "Bearer " }
        //     }
        // };

        // var httpClient = _httpClientFactory.CreateClient();
        // var httpResponseMessage = await httpClient.SendAsync(httpRequestMessage);

        // if (httpResponseMessage.IsSuccessStatusCode)
        // {
        //     using var contentStream =
        //         await httpResponseMessage.Content.ReadAsStreamAsync();
            
        //     GitHubBranches = await JsonSerializer.DeserializeAsync
        //         <IEnumerable<GitHubBranch>>(contentStream);
        // }
    }

    private string GetAccessToken()
    {
        
        return "";
        // var accounts = app.GetAccountsAsync().Result;

        // AuthenticationResult result = null;
        // try
        // {
        //     result = await app.AcquireTokenSilent(scopes, accounts.FirstOrDefault())
        //                     .ExecuteAsync();
        // }
        // catch (MsalUiRequiredException ex)
        // {
        //     // A MsalUiRequiredException happened on AcquireTokenSilent.
        //     // This indicates you need to call AcquireTokenInteractive to acquire a token
        //     Debug.WriteLine($"MsalUiRequiredException: {ex.Message}");

        //     try
        //     {
        //         result = await app.AcquireTokenInteractive(scopes)
        //                         .ExecuteAsync();
        //     }
        //     catch (MsalException msalex)
        //     {
        //         ResultText.Text = $"Error Acquiring Token:{System.Environment.NewLine}{msalex}";
        //     }
        // }
        // catch (Exception ex)
        // {
        //     ResultText.Text = $"Error Acquiring Token Silently:{System.Environment.NewLine}{ex}";
        //     return;
        // }

        // if (result != null)
        // {
        //     string accessToken = result.AccessToken;
        //     // Use the token
        // }
    }
}
