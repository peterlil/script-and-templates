using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http;

namespace ServerNameWeb.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    [BindProperty]
    public string? Fqdn { get; set; }
    public string? ServerName { get; private set; }


    public IndexModel(ILogger<IndexModel> logger, IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
    }

    public async Task OnGetAsync()
    {
        // No API call on GET
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (!string.IsNullOrWhiteSpace(Fqdn))
        {
            var client = _httpClientFactory.CreateClient();
            try
            {
                // Use http for demo, adjust as needed
                var url = $"http://{Fqdn}:5222/servername";
                ServerName = await client.GetStringAsync(url);
            }
            catch (Exception ex)
            {
                ServerName = $"Error: {ex.Message}";
            }
        }
        return Page();
    }

}
