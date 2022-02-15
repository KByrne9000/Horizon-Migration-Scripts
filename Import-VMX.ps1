<#
.SYNOPSIS
    Import-VMX.ps1
.VERSION
    .8b
.DESCRIPTION
    Attempts to Import all VMX file, on all Datastores, on a specific Datacenter
.NOTES
    Author(s): Christopher Thayer and Kevin Byrne
    Requirements:  
    Make sure the VMware PowerCLI is installed
    https://developer.vmware.com/powercli/installation-guide
#>

$vCenter = "SERVER"                   # vCenter / vSphere your connecting to
$datacenterName = "DATACENTER"                       # Name of the virtual datacenter in vCenter (Determines datastores being scanned)
$vmFolder = "VSPHER FOLDER"                                   # Folder to import VMs into
$hostCluster = "CLUSTER"                                      # Cluster to register VMs on
$OldNetworkPortGroup = "PREVIOUS NETWORK"                               # Old Network
$NewNetworkPortGroup = "CURRENT NETWORK"     # New Network
$logfilePath = "PATH"      # Path of Log File for Script

Start-Transcript -Path "$logfilePath" -Append

#Connect to vCenter
try {
    Write-Output "", "Connecting to vSphere Sever....."
    Connect-VIServer -Server $vCenter
    }
catch {
    Write-Output "", "---------------Not connected, cannot continue!---------------", ""
    Stop-Transcript
    exit -1
    }

# DEBUG Remove for Production
$datastoreList = "Pure-VDI-Test"
#Enable for Production
###$datastoreList = (get-childitem -path "vmstores:\$vCenter@443\$datacenterName")
Write-Output "", "The Following Datastores were found: ", $datastoreList

foreach ($ds in $datastoreList) {
    
    #Checking The datastore for all VMX Files
    Write-Output "", "*** Scanning $ds for VMX files...***", ""
    $vmxList = Get-Childitem -Path "vmstores:\$vCenter@443\$datacenterName\$ds" -Recurse | where { $_.Name -like "*.vmx" }
    
    foreach ($vmConfigFile in $vmxList) {
        
        #Reset the loop and check each VMX to see if it has already been imported or exists
        $vm = $null
        $import = $false
        $vmName = $vmConfigFile.name.replace(".vmx","")
        Write-Output "====================================="
        Write-Output "", "Checking if VM $vmName is found in vCenter..."
        $vm = Get-VM $vmName -ErrorAction SilentlyContinue
        
        if (-not $vm) {
            Write-Output "$vmName does not exist in vCenter.", ""
            $import = $true
        }
        else {
            Write-Output "$vmName is already in vCenter. SKIPPING!", ""
            $import = $false
        }
        
        # Import the VM if needed
        if ($import) {
            
            # Get host with the most available memory (Make sure DRS is on
            $targetHost = (Get-Cluster $hostCluster | Get-VMHost | Sort -Property MemoryUsageGB)[0]

            # Register the VM
            try {
                New-VM -VMHost $targetHost -Name $vmName -Location $vmFolder -VMFilePath $($vmConfigFile.DatastoreFullPath) | Out-Null
                #Change the Old Network to your current Portgroup
                Get-VM $vmName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetworkPortGroup} |Set-NetworkAdapter -Portgroup $NewNetworkPortGroup -Confirm:$false
                Write-Output "I have registered $vmName on the host $targetHost and updated the network to $NewNetworkPortGroup", ""
                }
            catch {
                Write-Output "Import was not successful!", ""                               
                }
        }
    }
}

Write-Output "", "*************** Importing Complete!***************", ""
Disconnect-VIServer -Server $vCenter -Confirm:$false
Stop-Transcript | Out-Null
