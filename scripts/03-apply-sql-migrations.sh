#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
sqlserver_starts_with='sql-azure-container-hosting'
sqldb_starts_with='sqldb-beer-voting'
sqladmin_username='sqladmin'
sqladmin_password='P@ssw0rd1234!'


echo "🔎 Get SQL db server starting with '${sqlserver_starts_with}'"
sqlserver_json_data=$(az sql server list --query "[?starts_with(name, '${sqlserver_starts_with}')].{name: name, resourceGroup: resourceGroup}[0]" -o json)
sqlserver_name=$(echo $sqlserver_json_data | jq -r '.name')
sqlserver_resourceGroup=$(echo $sqlserver_json_data | jq -r '.resourceGroup')
echo "🐕 Retrieved '${sqlserver_name}' on resource group '${sqlserver_resourceGroup}'"

echo "🔎 Get SQL db database starting with '${sqldb_starts_with}'"
sqldb_name=$(az sql db list --resource-group $sqlserver_resourceGroup --server $sqlserver_name --query "[?starts_with(name, '${sqldb_starts_with}')].name" -o tsv)
echo "🐕 Retrieved database '${sqldb_name}'"

echo "🧱 Add firewall rule to allow sql connection from client"
public_ip=$(curl -s https://ifconfig.io)
az sql server firewall-rule create -g $sqlserver_resourceGroup -s $sqlserver_name -n script-ef-update --start-ip-address $public_ip --end-ip-address $public_ip -o table
echo "🔨 Firewall rule added for ip"

echo "🪢 Get connection string"
sql_connection_string_template=$(az sql db show-connection-string -s $sqlserver_name -n $sqldb_name --auth-type SqlPassword --client ado.net -o tsv)
echo "🧵 Got connection string"

echo "🔁 Replace placeholders in connection string"
sql_connection_string=$(echo $sql_connection_string_template | sed "s|<username>|$sqladmin_username|g; s|<password>|$sqladmin_password|g")
echo "🦖 Replaced!"

echo "✨ Applying migrations from backend"
dotnet ef database update --connection "$sql_connection_string" --startup-project "${script_dir}/../src/Demo.BeerVoting.Backend" --context BeerDbContext -- --environment Production
echo "🍰 Migrations applied"

echo "🌱 Seed data"
ASPNETCORE_ENVIRONMENT=Production dotnet run --project "${script_dir}/../src/Demo.BeerVoting.Backend" --environment Database__UseInMemoryDatabase=false --environment Database__UseAutoMigration=false --environment Database__UseDataSeeding=true --environment ConnectionStrings__Beer="${sql_connection_string}" --seed
echo "🪴 Data planted"

echo '✅ Script finished!'
