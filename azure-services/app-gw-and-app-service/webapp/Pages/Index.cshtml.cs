using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;

namespace webapp.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;
        private readonly IConfiguration _configuration;

        public IndexModel(ILogger<IndexModel> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            ApiUri = String.Empty;
            WeatherSummary = String.Empty;
        }

        public void OnGet()
        {
            ApiUri = _configuration["BackendAPI"];
            CallingIp = string.Format("{0}:{1}", Request.HttpContext.Connection.RemoteIpAddress, Request.HttpContext.Connection.RemotePort);
            if(string.IsNullOrEmpty(ApiUri)) {
                WeatherSummary = "No backend configured";
            }
            else 
            {
                try
                {
                    HttpClient httpClient = new HttpClient { BaseAddress = new Uri(ApiUri) };
                    Task<string> taskReturn =  httpClient.GetStringAsync("/WeatherForecast");
                    taskReturn.Wait();
                    WeatherSummary = taskReturn.Result;
                }
                catch (AggregateException ex)
                {
                    foreach (var e in ex.InnerExceptions) {
                        WeatherSummary += string.Format("Error when calling backend: {0} ### ", ex.ToString());                            
                    }
                    
                }
            }
        }

        public string ApiUri{ get; set; }

        public string CallingIp { get; set; }

        public string WeatherSummary { get; set; }
    }
}