# 🚨🚨🚨
# Use bake file in project root to build container image

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app
EXPOSE 5179

# Install ICU for globalization support
# https://github.com/dotnet/dotnet-docker/blob/main/samples/enable-globalization.md
# see https://github.com/dotnet/SqlClient/issues/2239
RUN apk add --no-cache icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

ENV ASPNETCORE_URLS=http://+:5179

USER app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release

WORKDIR /src
COPY ["Directory.Packages.props", "./"]
COPY ["nuget.config", "./"]
COPY ["src/Demo.BeerRating.Frontend/Demo.BeerRating.Frontend.csproj", "/src/Demo.BeerRating.Frontend/"]

RUN dotnet restore "/src/Demo.BeerRating.Frontend/Demo.BeerRating.Frontend.csproj"
COPY ["src/Demo.BeerRating.Frontend", "/src/Demo.BeerRating.Frontend"]
WORKDIR "/src/Demo.BeerRating.Frontend"
RUN dotnet build "Demo.BeerRating.Frontend.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "Demo.BeerRating.Frontend.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Demo.BeerRating.Frontend.dll"]
