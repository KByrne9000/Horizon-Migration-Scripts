#Primary Variables
$horizonServer = "vcs.titleonecorp.com"
$username = "byrnekevx"
$password = "Thebestdane4ever!"
$domain = "NRTShared"

#File location variable
$fileloc = "C:\Powershell-Logs\HorizonDB"
$logfilePath = "C:\Powershell-Logs\Import.txt"

#Connect to the Horizon Environment
Write-Output "", "Connect to the Connection Server" 
Connect-HVServer -Server $horizonServer -Domain $domain -user $username -Password $password

#Import Horizon pool entitlement information from separate txt files
Write-Output "", "Connection Server pool import"
$pools = "Test-PSScript"     #For Validation using a Fixed Valiable

ForEach ($pool in $pools) {
    Write-Output ''
    $Entitlements = Get-Content "$fileloc\$pool.txt"
    Write-Output 'Adding Entitlements :'
    Write-Output ''
    Write-Output $Entitlements 
        ForEach ($Entitlement in $Entitlements) {
            Write-Output "I am going to run New-HVEntitlement -User $Entitlement -ResourceName $pool -Confirm:$false"
            New-HVEntitlement -User $Entitlement -ResourceName $pool -Confirm:$false
            Write-Output ''
        }
    }
    Write-Output 'Entitlements Complete!'
