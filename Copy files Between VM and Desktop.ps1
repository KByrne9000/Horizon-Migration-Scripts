
$vCenter = "dpvttovctr01.shared.corp.nrt"

Connect-VIServer -Server $vCenter

Copy-VMGuestFile -Destination c:\powershell-logs\ -GuestToLocal -Source c:\LDports\Test.zip -GuestPassword Bl@ckNg0ld -GuestUser Administrator -VM GoldImage-Win10