using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Azure.Identity;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;

var builder = WebApplication.CreateBuilder(args);

string[] scopes = builder.Configuration.GetValue<string>("obo-api-server-sample:UseApi").Split(' '); // ?

// Add services to the container.
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"), "OpenIdConnect", "Cookies", true)
        .EnableTokenAcquisitionToCallDownstreamApi(scopes)
            .AddInMemoryTokenCaches();

string appConfigCnStr = builder.Configuration.GetConnectionString("AppConfig");
builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(appConfigCnStr)
        .ConfigureKeyVault(async kv =>
        {
            /*
            var o = new DefaultAzureCredentialOptions();
            o.SharedTokenCacheUsername = "peterlil@mngenv319828.onmicrosoft.com";
            kv.SetCredential(new DefaultAzureCredential(o));
            */
            kv.SetCredential(new DefaultAzureCredential());
        });
});

/*
https://stackoverflow.com/questions/61524182/msal-net-no-account-or-login-hint-was-passed-to-the-acquiretokensilent-call
https://stackoverflow.com/questions/62518766/error-no-account-or-login-hint-was-passed-to-the-acquiretokensilent-call
https://stackoverflow.com/questions/60524263/account-not-found-after-restart-no-account-or-login-hint-was-passed-to-the-acqu
https://learn.microsoft.com/en-us/azure/active-directory/develop/msal-net-token-cache-serialization?tabs=aspnetcore
https://learn.microsoft.com/en-us/azure/azure-app-configuration/quickstart-aspnet-core-app?tabs=core6x
https://www.youtube.com/watch?v=TU82BTmeNeU
https://localhost:7286/
https://learn.microsoft.com/en-us/answers/questions/714417/unable-to-retrieve-password-from-keyvault-error-ak.html
https://github.com/Azure/azure-cli/issues/11871
https://www.rahulpnath.com/blog/defaultazurecredential-from-azure-sdk/
*/

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

