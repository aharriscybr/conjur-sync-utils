
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

    $C = Get-Credential

    $client = [System.Web.HttpUtility]::UrlEncode($C.UserName)
    $type = "client_credentials"
    $secret = [System.Web.HttpUtility]::UrlEncode($C.GetNetworkCredential().Password)

    if ( $isu -eq $false ) {

        $authnUrl = "https://" + $privdomain + ".privilegecloud.cyberark.cloud/PasswordVault/api/auth/Cyberark/Logon"
        $method = "POST"

        $body = @{

            username = $client
            password = $secret
        }

        $jBody = $body | ConvertTo-Json
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")

        try {

            $localToken = Invoke-RestMethod -Method $Method -Body $jBody -Uri $authnUrl

            return $localToken

        } catch {

            Write-Host $_

        } 

    }

    } elseif ( $isu -eq $true ) {

        $authnUrl = "https://" + $tenant + ".id.cyberark.cloud/oauth2/platformtoken"
        $method = "POST"

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

function Set-Admins() {

    $g = "Vault Admins"
    $t = "Group"
    $safeAdminPermission = @{
        useAccounts                            = $True
        retrieveAccounts                       = $True
        listAccounts                           = $True
        addAccounts                            = $True
        updateAccountContent                   = $True
        updateAccountProperties                = $True
        initiateCPMAccountManagementOperations = $True
        specifyNextAccountContent              = $True
        renameAccounts                         = $True
        deleteAccounts                         = $True
        unlockAccounts                         = $True
        manageSafe                             = $True
        manageSafeMembers                      = $True
        backupSafe                             = $True
        viewAuditLog                           = $True
        viewSafeMembers                        = $True
        accessWithoutConfirmation              = $True
        createFolders                          = $True
        deleteFolders                          = $True
        moveAccountsAndFolders                 = $True
        requestsAuthorizationLevel1            = $True
        requestsAuthorizationLevel2            = $False
    }

    $body = @{
        $memberName = $g
        $MemberType = $t
        permissions = $safeAdminPermission
    }

    $jBody = $body | ConvertTo-Json
    $uri = "https://$privdomain.privilegecloud.cyberark.cloud/passwordvault/api/safes/$safe"

    $session = Set-TokenData
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", $session)

    try {

        Invoke-RestMethod -Method $Method -Body $jBody -Uri $uri -Header $headers

    } catch {

        Write-Host $_.Exception.ResponseCode
        Write-Host $_

    } 

    

}

Initialize-Environment