using Microsoft.Extensions.Configuration;

public class App
{
    private static readonly List<Quote> Quotes =
    [
        new("Bier ist eine wahrhaft göttliche Medizin.",
            "Philippus \"Paracelsus\" Theophrastus Aureolus Bombast von Hohenheim"),
        new("Bier ist der überzeugendste Beweis dafür, dass Gott den Menschen liebt und ihn glücklich sehen will.",
            "Benjamin Franklin"),
        new("Es ist ein Grundbedürfnis der Deutschen, beim Biere schlecht über die Regierung zu reden",
            "Otto von Bismarck"),
        new("Das beste am Wein ist das Bier danach.",
            "Günter Samtlebe"),
        new("I think this would be a good time for a beer.",
            "Franklin D. Roosevelt"),
        new("Man könnte froh sein, wenn die Luft so rein wäre wie das Bier.",
            "Richard von Weizsäcker"),
       new ("Wer kein Bier hat, hat nichts zu trinken.",
            "Martin Luther")
    ];

    private readonly int _quoteSleepInSeconds;

    public App(IConfiguration configuration)
    {
        // You can use the configuration if needed
        int? quoteSleepInSeconds = configuration.GetValue<int?>("QuoteSleepInSeconds");
        if (!quoteSleepInSeconds.HasValue || quoteSleepInSeconds <= 0)
        {
            throw new ArgumentException("QuoteSleepInSeconds must be a positive integer in appsettings.json");
        }
        _quoteSleepInSeconds = quoteSleepInSeconds.Value;
    }

    public async Task RunAsync()
    {
        // print a random quote every 5 minutes
        Random random = new Random();
        while (true)
        {
            int index = random.Next(Quotes.Count);
            Quote randomQuote = Quotes[index];
            Console.WriteLine($"\"{randomQuote.Text}\" - {randomQuote.Author}");

            await Task.Delay(TimeSpan.FromSeconds(_quoteSleepInSeconds));
        }
    }
}

public record Quote(string? Text, string? Author);
