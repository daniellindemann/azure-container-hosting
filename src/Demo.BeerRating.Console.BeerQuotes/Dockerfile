# 🚨🚨🚨
# Use bake file in project root to build container image

FROM mcr.microsoft.com/dotnet/runtime:9.0-alpine AS base
WORKDIR /app
USER app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["Directory.Packages.props", "./"]
COPY ["nuget.config", "./"]
COPY ["src/Demo.BeerRating.Console.BeerQuotes/Demo.BeerRating.Console.BeerQuotes.csproj", "/src/Demo.BeerRating.Console.BeerQuotes/"]
RUN dotnet restore "/src/Demo.BeerRating.Console.BeerQuotes/Demo.BeerRating.Console.BeerQuotes.csproj"
COPY ["src/Demo.BeerRating.Console.BeerQuotes", "/src/Demo.BeerRating.Console.BeerQuotes"]
WORKDIR "/src/Demo.BeerRating.Console.BeerQuotes"
RUN dotnet build "Demo.BeerRating.Console.BeerQuotes.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "Demo.BeerRating.Console.BeerQuotes.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Demo.BeerRating.Console.BeerQuotes.dll"]
