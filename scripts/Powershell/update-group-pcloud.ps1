
Add-Type -AssemblyName System.Web

function Initialize-Environment(){
    [CmdletBinding()]
    param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $IdentityTenant,
        [Parameter(Position=1,mandatory=$true)]
        [string] $PrivDomain,
        [Parameter(Position=2,mandatory=$true)]
        [string] $SafeName
    )

    $global:tenant = $IdentityTenant
    $global:privdomain = $PrivDomain
    $global:safe = $SafeName
    $global:type = $AuthnType

}

function Set-TokenData(){
    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $tenant
    )

    $C = Get-Credential

    $authnUrl = "https://" + $tenant + ".id.cyberark.cloud/oauth2/platformtoken"
    $method = "POST"

    $client = [System.Web.HttpUtility]::UrlEncode($C.UserName)
    $type = "client_credentials"
    $secret = [System.Web.HttpUtility]::UrlEncode($C.GetNetworkCredential().Password)

    $body = "client_id=" + $client + "&grant_type=" + $type + "&client_secret=" + $secret

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

    $headers.Add("Content-Type", "application/x-www-form-urlencoded")

    try {

        $localToken = Invoke-RestMethod -Method $Method -Body $body -Uri $authnUrl

        return "Bearer " + $localToken.access_token

    } catch {

        Write-Host $_

    } 

}

#Initialize-Environment