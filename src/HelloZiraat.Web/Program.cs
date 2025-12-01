var builder = WebApplication.CreateBuilder(args);

// Web uygulaması 52369 portunu dinlesin:
builder.WebHost.UseUrls("http://0.0.0.0:52369");

// MVC (Controller + View) kullanacağız
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Geliştirme ortamı için ekstra bir şeye gerek yok,
// sadece basit pipeline kalsın. Hata sayfa vb. önemli değil şu an.

// HTTPS yönlendirmeyi KALDIRIYORUZ, sade olsun diye:
// app.UseHttpsRedirection();
// app.UseHsts();

app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

// Varsayılan route: HomeController / Index action
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
