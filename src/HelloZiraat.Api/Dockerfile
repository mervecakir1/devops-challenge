# 1. AŞAMA: BUILD (derleme) aşaması
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Projedeki tüm dosyaları container içindeki /src klasörüne kopyala
COPY . .

# Release modda publish et, çıktıyı /app klasörüne al
RUN dotnet publish -c Release -o /app

# 2. AŞAMA: RUNTIME (çalışma) aşaması
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Build aşamasında oluşan /app içeriğini runtime imajına kopyala
COPY --from=build /app ./

# Uygulamanın dinleyeceği adres: 0.0.0.0:11130
ENV ASPNETCORE_URLS=http://0.0.0.0:11130

# Container içinde açacağımız port
EXPOSE 11130

# Uygulamayı başlat
ENTRYPOINT ["dotnet", "HelloZiraat.Api.dll"]
