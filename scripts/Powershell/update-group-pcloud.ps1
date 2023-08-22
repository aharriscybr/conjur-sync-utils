
Add-Type -AssemblyName System.Web

function Initialize-Environment(){
    <#
    .SYNOPSIS
    Configure Script to Authenticate and Update Synchronizer Safe Data.
    .PARAMETER IdentityTenant
    The ISPSS Tenant (e.g. ####)
    .PARAMETER PrivDomain
    The PVWA server domain (e.g. sample-domain)
    .PARAMETER SafeName
    The Synchronizer Safe Name(e.g. ConjurSync
    #>
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
    
    $loop = $true

    while($loop){
        $chc = Read-Host -Prompt "Are you using installeruser@cyberark.cloud.####? (y/n)"
        switch ($chc) {
            'y' {
                Write-Host "Using installer user for authentication."
                $global:isu = $true
                $loop = $false
            }
            'n' {
                Write-Host "Using local admin user for authentication."
                $global:isu = $false
                $loop = $false
            }
            Default {
                Write-Host "Invalid input received, please answer with y or n."
            }
        }
    }

}

function Set-TokenData(){
    param(
        [Parameter(Position=0,mandatory=$true)]
        [string] $tenant
        [Parameter(Position=1,mandatory=$true)]
        [string] $type
        [Parameter(Position=2,mandatory=$true)]
        [string] $PrivDomain
    )

    $C = Get-Credential

    $client = [System.Web.HttpUtility]::UrlEncode($C.UserName)
    $type = "client_credentials"
    $secret = [System.Web.HttpUtility]::UrlEncode($C.GetNetworkCredential().Password)

    if ( $isu -eq $false ) {

    } elseif ( $isu -eq $true ) {

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

}

Initialize-Environment