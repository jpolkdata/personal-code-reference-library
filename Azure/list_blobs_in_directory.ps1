###################################################################################
## List the blobs that are contained in a given path in blob storage
###################################################################################

# Azure Instance Information
$storageAccount = "{STORAGE_ACCOUNT_NAME}";
$sasToken = "{SAS_TOKEN}";
$container = "{STORAGE_CONTAINER_NAME}";

# Azure Context
$az = New-AzStorageContext -StorageAccountName $storageAccount -SasToken $sasToken;

# Get the blobs list and then sort them
$prefix = "PATH/TO/FILES/";
$blobs = Get-AzStorageBlob -Container $container -Context $az -Prefix $prefix | sort @{expression="Name";Descending=$false};

foreach ($blob in $blobs)
{
    if($blob.name.Contains("CLAIM"))
    {
        echo $blob.name;
    }
}
