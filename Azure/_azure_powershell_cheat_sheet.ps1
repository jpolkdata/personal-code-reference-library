## AZURE POWERSHELL CHEAT SHEET ##

# Get a simple list of the resources that exist in Azure
Get-AzResource | ft

# Get just a subset of resources (in this case SQL databases)
Get-AzResource -ResourceType Microsoft.Sql/servers/databases | fl

# Get a subset of resources (in this case Cosmos DBs) and a more robust set of properties
Get-AzResource -Name *cosmos* | fl -property * 
