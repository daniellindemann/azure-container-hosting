# 🚨🚨🚨
# Dockerfile needs to be used with context of the mono repo
# see ../../Readme.md#build-image-for-frontend

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS base
WORKDIR /app
EXPOSE 5179

ENV ASPNETCORE_URLS=http://+:5179

USER app

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release

WORKDIR /src
COPY ["Directory.Packages.props", "./"]
COPY ["nuget.config", "./"]
COPY ["src/Demo.BeerVoting.Frontend/Demo.BeerVoting.Frontend.csproj", "/src/Demo.BeerVoting.Frontend/"]

RUN dotnet restore "/src/Demo.BeerVoting.Frontend/Demo.BeerVoting.Frontend.csproj"
COPY ["src/Demo.BeerVoting.Frontend", "/src/Demo.BeerVoting.Frontend"]
WORKDIR "/src/Demo.BeerVoting.Frontend"
RUN dotnet build "Demo.BeerVoting.Frontend.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "Demo.BeerVoting.Frontend.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Demo.BeerVoting.Frontend.dll"]
