using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Azure.Identity;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;

var builder = WebApplication.CreateBuilder(args);

string[] scopes = new string[]
{
    builder.Configuration.GetValue<string>("obo-api-client-sample:Scopes")
};

// Add services to the container.
builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"), "OpenIdConnect", "Cookies", true)
        .EnableTokenAcquisitionToCallDownstreamApi(scopes)
            .AddInMemoryTokenCaches();

// If using Azure App Configuration instead of appsettings.json
//string appConfigCnStr = builder.Configuration.GetConnectionString("AppConfig");
//builder.Configuration.AddAzureAppConfiguration(options =>
//{
//    options.Connect(appConfigCnStr)
//        .ConfigureKeyVault(async kv =>
//        {
//            kv.SetCredential(new DefaultAzureCredential());
//        });
//});



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

// Below from https://stackoverflow.com/questions/51921885/why-claimsprincipal-current-is-returned-null-even-when-the-user-is-authenticated
// Populates System.Security.Claims.ClaimsPrincipal.Current
app.Use((context, next) =>
{
    Thread.CurrentPrincipal = context.User;
    return next(context);
});

app.Run();

