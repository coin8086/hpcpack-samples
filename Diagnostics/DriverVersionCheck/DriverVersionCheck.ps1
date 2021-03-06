# Usage: DriverVersionCheck.ps1 <Network>
Param(
    [Parameter(Mandatory=$true)] 
    [string] $Network
)

# Wrap in try-catch to handle any unexpected exceptions.
try {

    # Get all network drivers.
    $NAall = Get-WmiObject win32_networkAdapter | where { $_.PhysicalAdapter -eq "TRUE"}
    $SDall = Get-WmiObject win32_PnPSignedDriver

    # Look for network with name = $Network.

    $i = 0;
    do
    {
        if ($NAall.length -le 0)
        {
            # Only one network adapter is found in the system, NAall is the adapter itself.
            $NA = $NAall;
        }
        else
        {
            $NA = $NAall[$i];
        }

        $SD = $SDall | where {$_.DeviceID -eq $NA.PnPDeviceID}

        if ($NA.NetConnectionID.compareto($Network) -eq 0)
        {
        
            # Found matching network: write driver version to stdout.
            Write-Output $SD.DriverVersion

            # Exit.
            return
            
        }

        $i ++;
    } while ($NAall.length -gt $i);

    # No network adapter named $Network found.
    $Msg = -join ("No network named ", $Network, " found")
    Write-Output $Msg
    return
    
} 
catch [Exception]
{

    # Print exception message to stdout.
    "DriverVersionCheck.ps1: Terminated by unknown exception"
    Write-Host ("Exception " + $_.InvocationInfo.PositionMessage);
    Write-Host $_.Exception.Message;
    Write-Host ("Exception Class: " + $_.Exception.GetType().FullName);

}