using System.Text.Json.Serialization;
namespace obo_web_client
{
    public class TemperatureSample
    {
        [JsonPropertyName("date")]
        public DateTime Date { get; set; }
        [JsonPropertyName("temperatureC")]
        public int TemperatureC { get; set; }
        [JsonPropertyName("summary")]
        public string Summary { get; set; }
    }
}
