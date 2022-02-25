<#
.SYNOPSIS
    Import-HVPools.ps1
.VERSION
    .8b
.DESCRIPTION
    Imports all the pools from a JSON File, adds them to an existing Horizon Connection Server, and entitles those pools from a TXT file.
.NOTES
    Author(s): Kevin Byrne
    Requirements:  
    Make sure the VMware.HV.Helper module is installed, see: https://github.com/vmware/PowerCLI-Example-Scripts
    Copy the VMware.Hv.Helper to the module location.
#>

#Login variables
$horizonServer = Read-Host -Prompt "Enter the Horizon Connection Server Name"
$username = Read-Host -Prompt "Enter the Username (without the domain name)"
$password = Read-Host -Prompt "Enter the Password" -AsSecureString
$domain = Read-Host -Prompt "Enter the Horizon AD Domain"

#DEBUG login variables
$horizonServer = "SERVER"
$username = "USER"
$domain = "DOMAIN"

#File location variable
$fileloc = "PATH"
$logfilePath = "PATH2"

Start-Transcript -Path "$logfilePath" -Append

#Connect to the Horizon Environment
Write-Output "", "Connect to the Connection Server" 
Connect-HVServer -Server $horizonServer -Domain $domain -user $username -Password $password

#Importing each pools configuration from individual JSON files, and the Entitlements from individual TXT files
Write-Output "", "Connection Server pool import!", ""
#DEBUG For Validation using a Fixed Valiable
#$Pools = "Test-PSScript"
#For Production use
$Poolraw = get-childitem -Path "$fileloc" | where { $_.Name -like "*.json" }
                foreach ($Pool in $Poolraw) {                             
                $Pools = $Poolraw.name.replace(".json","")
           }
Write-Output "Importing these pools to the Horizon Server: ", $Pools


ForEach ($Pool in $Pools) {
    Write-Output "", "============================================="
    #Importing the Pool from a JSON file
    Write-Output "", "Import pool: $Pool", ""
    
            if ((Get-HVPool $Pool -SuppressInfo:$true).base.name -ne $Pool) {
                New-HVPool -PoolName $Pool -Spec $fileloc\$Pool.json -Confirm:$false | Out-Null
                Start-Sleep -Seconds 5
                #Importing the Entitlments from a TXT file
                $Entitlements = Get-Content "$fileloc\$Pool.txt"
                Write-Output "Adding Entitlements: $Entitlements", "" 
                ForEach ($Entitlement in $Entitlements) {
                    New-HVEntitlement -User $Entitlement -ResourceName $Pool
                    }
                }
            else {
                Write-Output "Pool already exists!"                              
                }
    }

Write-Output "", "", "************** Import Complete! **************", ""
Disconnect-HVServer -Server $horizonServer -Confirm:$false
Stop-Transcript | Out-Null
