## AZURE BASH CLI CHEAT SHEET ##

# Get a simple list of Azure resources
az resource list --output table

# Get a subset of resources (in this case SQL databases)
az resource list --resource-type 'Microsoft.Sql/Servers/databases' --output table

# Get a subset of resources using the query syntax (in this case Cosmos DBs)
az resource list --query "[?contains(name, 'cosmos')]" --output yaml
