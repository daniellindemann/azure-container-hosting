# 🚨🚨🚨
# Dockerfile needs to be used with context of the mono repo
# see ../../Readme.md#build-image-for-backend

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app
EXPOSE 5178

ENV ASPNETCORE_URLS=http://+:5178

USER app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release

WORKDIR /src
COPY ["Directory.Packages.props", "./"]
COPY ["nuget.config", "./"]
COPY ["src/Demo.BeerVoting.Backend/Demo.BeerVoting.Backend.csproj", "/src/Demo.BeerVoting.Backend/"]

RUN dotnet restore "/src/Demo.BeerVoting.Backend/Demo.BeerVoting.Backend.csproj"
COPY ["src/Demo.BeerVoting.Backend", "/src/Demo.BeerVoting.Backend"]
WORKDIR "/src/Demo.BeerVoting.Backend"
RUN dotnet build "Demo.BeerVoting.Backend.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "Demo.BeerVoting.Backend.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Demo.BeerVoting.Backend.dll"]
