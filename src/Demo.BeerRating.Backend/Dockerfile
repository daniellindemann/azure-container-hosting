# 🚨🚨🚨
# Dockerfile needs to be used with context of the mono repo
# see ../../Readme.md#build-image-for-backend

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app
EXPOSE 5178

# Install ICU for globalization support
# https://github.com/dotnet/dotnet-docker/blob/main/samples/enable-globalization.md
# see https://github.com/dotnet/SqlClient/issues/2239
RUN apk add --no-cache icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

ENV ASPNETCORE_URLS=http://+:5178

USER app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release

WORKDIR /src
COPY ["Directory.Packages.props", "./"]
COPY ["nuget.config", "./"]
COPY ["src/Demo.BeerRating.Backend/Demo.BeerRating.Backend.csproj", "/src/Demo.BeerRating.Backend/"]

RUN dotnet restore "/src/Demo.BeerRating.Backend/Demo.BeerRating.Backend.csproj"
COPY ["src/Demo.BeerRating.Backend", "/src/Demo.BeerRating.Backend"]
WORKDIR "/src/Demo.BeerRating.Backend"
RUN dotnet build "Demo.BeerRating.Backend.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "Demo.BeerRating.Backend.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Demo.BeerRating.Backend.dll"]
