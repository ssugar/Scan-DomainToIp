param(
  $dns,
  $onlyTrueFlag=0
)
$file = Get-Content .\hosts.txt
$lines = $file.Split([Environment]::NewLine)
foreach($line in $lines)
{
    $hostname = $line + "." + $dns
    Try
    {
        [System.Net.Dns]::GetHostAddresses($hostname) | foreach {write-host $hostname "resolves to" $_.IPAddressToString }
    }
    Catch
    {
        if($onlyTruFlag -eq 0){write-host $hostname "not found"}
    }
}