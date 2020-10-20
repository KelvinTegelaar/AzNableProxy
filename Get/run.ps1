using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)


# Define the command-line parameters to be used by the script


$serverHost = $ENV:NableHostname
$JWT = $ENV:JWTKey
$SpecifiedCustomerID = $Request.Query.ID
# Generate a pseudo-unique namespace to use with the New-WebServiceProxy and
# associated types.
$NWSNameSpace = "NAble" + ([guid]::NewGuid()).ToString().Substring(25)
$KeyPairType = "$NWSNameSpace.T_KeyPair"

# Bind to the namespace, using the Webserviceproxy
$bindingURL = "https://" + $serverHost + "/dms/services/ServerEI?wsdl"
$nws = New-Webserviceproxy $bindingURL -Namespace ($NWSNameSpace)

# Set up and execute the query
$KeyPair = New-Object -TypeName $KeyPairType
$KeyPair.Key = 'listSOs'
$KeyPair.Value = "false"
Try {
    $CustomerList = $nws.customerList($username, $JWT, $KeyPair)
}
Catch {
    Write-Host "Could not connect: $($_.Exception.Message)"
    exit
}
do {
    # Set up the "Customers" array, then populate
    $Customers = ForEach ($Entity in $CustomerList) {
        $CustomerAssetInfo = @{}
        ForEach ($item in $Entity.Info) { $CustomerAssetInfo[$item.key] = $item.Value }
        [PSCustomObject]@{
            ID                = $CustomerAssetInfo["customer.customerid"]
            RegistrationToken = $CustomerAssetInfo["customer.registrationtoken"]
        }
    }
} while ($null -eq $Customers)

$Output = $Customers | Where-Object { $_.ID -eq $SpecifiedCustomerID }
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Output
    })