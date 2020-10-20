# AzNableProxy
This is a proxy to allow users to retrieve the installation keys for N-Central agents without having complete API access

# How to use

https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fKelvinTegelaar%2fAzureDeploy%2fmaster%2fAzNableProxy.json
Click on Deploy with Azure button, or download the script from https://github.com/KelvinTegelaar/AzNableProxy

Fill in your information:

*Basename:* anything you want, will be appended with 4 random characters.

*JWTKey*: Your N-Able JWT key. You can find this at the User management page, last tab called "API".

*Nable Hostname*: Your Nable hostname.

*Branch*: Currently only Master is available.

after creating the function, click on "Go to resource" then click on "Functions" and then "Get". Lastely click on "Get Function URL"

This can now be used to get the installation ID for a client. for example for client 101:

     <https://aznableproxy1234.azurewebsites.net/api/Get?code=SOMELONGCODEHERE&ID=101>

you can also use PowerShell to retrieve this ID easily:

     $ID = "101"
     invoke-restmethod -uri "https://aznableproxy1234.azurewebsites.net/api/Get?code=SOMELONGCODEHERE&ID=$($ID)"

# FAQ

Q: Why did you write out the XML and not use webservices?
A: SOAP is regarded legacy by Microsoft, and thus PowerShell 7 does not support Webservices anymore. to get them to work, you can write-out the XML and pass it with Invoke-Restmethod.

Q: Why an azure function?
A: We're a Microsoft house, and we don't like our actual N-central API key flying around. With this all the data you can get is an installation-ID for software. Not the biggest issue.