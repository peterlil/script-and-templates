using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Azure.Identity;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;

var builder = WebApplication.CreateBuilder(args);

/*
string[] clientApiScopes = builder.Configuration.GetValue<string>("obo-api-client-sample:Scopes").Split(' ');
string[] serverApiScopes = builder.Configuration.GetValue<string>("obo-api-server-sample:Scopes").Split(' ');
string[] scopes = clientApiScopes.Union(serverApiScopes).ToArray();
*/
string[] scopes = new string[]
{
    builder.Configuration.GetValue<string>("obo-api-client-sample:Scopes"),
    builder.Configuration.GetValue<string>("obo-api-server-sample:Scopes")
};

// Add services to the container.
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"), "OpenIdConnect", "Cookies", true)
        .EnableTokenAcquisitionToCallDownstreamApi(new[] { scopes[1] })
            .AddInMemoryTokenCaches();

string appConfigCnStr = builder.Configuration.GetConnectionString("AppConfig");
builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(appConfigCnStr)
        .ConfigureKeyVault(async kv =>
        {
            kv.SetCredential(new DefaultAzureCredential());
        });
});



builder.Services.AddAuthorization(options =>
{
    // By default, all incoming requests will be authorized according to the default policy.
    options.FallbackPolicy = options.DefaultPolicy;
});

builder.Services.AddRazorPages()
    .AddMicrosoftIdentityUI();

// Add HttpClient to the container.
builder.Services.AddHttpClient();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapRazorPages();
app.MapControllers();

app.Run();

