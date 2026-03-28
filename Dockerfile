# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY src/TaskFlow.Web/TaskFlow.Web.csproj TaskFlow.Web/
RUN dotnet restore TaskFlow.Web/TaskFlow.Web.csproj
COPY src/TaskFlow.Web/ TaskFlow.Web/
RUN dotnet publish TaskFlow.Web/TaskFlow.Web.csproj -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "TaskFlow.Web.dll"]
