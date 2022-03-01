using System;
using Microsoft.Identity.Client;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace MyDaemon // Note: actual namespace depends on the project name.
{
    internal class Program
    {
        static void Main(string[] args)
        {

            // Setup Host
            var host = CreateDefaultBuilder().Build();
            
            // Invoke Worker
            using IServiceScope serviceScope = host.Services.CreateScope();
            IServiceProvider provider = serviceScope.ServiceProvider;
            var workerInstance = provider.GetRequiredService<Worker>();
            workerInstance.DoWork();

            host.Run();
        }

        static IHostBuilder CreateDefaultBuilder()
        {
            return Host.CreateDefaultBuilder()
                .ConfigureAppConfiguration(app =>
                {
                    app.AddJsonFile("appsettings.json");
                })
                .ConfigureServices(services =>
                {
                    services.AddSingleton<Worker>();
                });
        }
    }

    internal class Worker
    {
        private readonly IConfiguration configuration;
        private readonly IHostEnvironment env;
        private string ClientId = string.Empty;
        private string ClientSecret = string.Empty;
        private string Authority = string.Empty;

        public Worker(IConfiguration configuration, IHostEnvironment env)
        {
            this.configuration = configuration;
            this.env = env;
        }


        public void DoWork()
        {
            var keyValuePairs = configuration.AsEnumerable().ToList();
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("==============================================");
            Console.WriteLine("Configurations...");
            Console.WriteLine("==============================================");
            foreach (var pair in keyValuePairs)
            {
                Console.WriteLine($"{pair.Key} - {pair.Value}");
            }
            Console.WriteLine("==============================================");
            Console.ResetColor();

            Console.WriteLine(env.EnvironmentName);


            string clientId = configuration["ClientId"];
            string clientSecret = configuration["ClientSecret"];
            string authority = configuration["Authority"];
            IConfidentialClientApplication app;
            app = ConfidentialClientApplicationBuilder.Create(clientId)
                                                      .WithClientSecret(clientSecret)
                                                      .WithAuthority(new Uri(authority))
                                                      .Build();



            Console.WriteLine("Hello World!");
        }
    }
}




