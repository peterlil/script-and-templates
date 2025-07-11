using Microsoft.Identity.Client;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class Program
    {
        private static HttpClient _sharedClient = new();

        static async Task Main(string[] args)
        {
            var configuration =  new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile($"appsettings.json");

            var config = configuration.Build();

            var app = PublicClientApplicationBuilder.Create(config["AzureAD:ClientId"])
                .WithAuthority(AzureCloudInstance.AzurePublic, config["AzureAD:TenantId"])
                .WithRedirectUri(config["AzureAD:RedirectUri"])
                .Build();
            
            string[] scopes = { config["Api1:Scope"] };

            AuthenticationResult result = await app.AcquireTokenInteractive(scopes).ExecuteAsync();

            Console.WriteLine($"Token:\t{result.AccessToken}");
            _sharedClient.BaseAddress = new Uri(config["Api1:BaseUrl"]);
            _sharedClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", result.AccessToken);
            _sharedClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            using HttpResponseMessage response = await _sharedClient.GetAsync("weatherforecast");

            if (response.IsSuccessStatusCode)
            {
                var responseContent = response.Content.ReadAsStringAsync().Result;
                var weatherForecast = JsonSerializer.Deserialize<List<TemperatureSample>>(responseContent);
                foreach (var sample in weatherForecast)
                {
                    Console.WriteLine($"Date: {sample.Date}, Temperature: {sample.TemperatureC}, Summary: {sample.Summary}");
                }
            }
        }
    }
}


