# 1. AŞAMA: BUILD (derleme)
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Web uygulamasının tüm dosyalarını container içine kopyala
COPY . .

# Release modda publish et, çıktıyı /app klasörüne al
RUN dotnet publish -c Release -o /app

# 2. AŞAMA: RUNTIME (çalışma)
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Build aşamasında oluşan yayın (publish) çıktısını al
COPY --from=build /app ./

# Uygulamanın dinleyeceği adres ve port
ENV ASPNETCORE_URLS=http://0.0.0.0:52369

# Container içindeki port bilgisini metadata olarak ekle
EXPOSE 52369

# Uygulamayı başlat
ENTRYPOINT ["dotnet", "HelloZiraat.Web.dll"]
