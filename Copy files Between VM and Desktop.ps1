
$vCenter = "FQDN Server"

Connect-VIServer -Server $vCenter

Copy-VMGuestFile -Destination c:\FILEPATH\FILE.EXT -GuestToLocal -Source c:\FILEPATH\FILE.EXT -GuestPassword LOCALPASSWORD -GuestUser LOCALADMIN -VM VMNAMEINVSPHERE
