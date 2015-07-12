param(
  $dns,
  [parameter()]
  [ValidateScript({
    If(Test-Path $_){$true}else{Throw "Invalid wordlist file given: $_"}
  })]
  [string[]]$wordlist,
  $onlyTrueFlag=0
)


$file = Get-Content $wordlist
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

$mxRecords = Nslookup -type=mx $dns 2> $null
$x=0
foreach($item in $mxRecords)
{
    if($x -gt 2) #skip over the server, address and blank line output from nslookup
    {
        write-host $item #write out just the mail exchanger lines
    }
    $x+=1
}

$txtRecords = Nslookup -type=txt $dns 2> $null
$x=0
foreach($item in $txtRecords)
{
    if($x -gt 2) #skip over the server, address and blank line output from nslookup
    {
        write-host $item #write out just the txt record lines
        if($item -match "v=spf1")
        {
            $segments = $item.Split(":")
            $targetSegment = ($segments[1].Split(" "))[0]
            $spfIps = Nslookup -type=txt $targetSegment 2> $null
            $y=0
            foreach($spfIp in $spfIps)
            {
                if($y -gt 2) #skip over the server, address and blank line output from nslookup
                {
                    write-host $spfIp
                }
                $y+=1
            }
        }
    }
    $x+=1
}
