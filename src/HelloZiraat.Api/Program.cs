var builder = WebApplication.CreateBuilder(args);

// Uygulama 11130 portunu dinlesin
builder.WebHost.UseUrls("http://0.0.0.0:11130");

var app = builder.Build();

// Root ("/") adresine gelene şu cevabı döndür
app.MapGet("/", () => "Hello Ziraat Team from Merve");

app.Run();
