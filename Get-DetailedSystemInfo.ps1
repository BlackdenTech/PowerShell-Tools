function Get-DetailedSystemInfo {
    
    #Credit where it's due, this is borrowed from "Learn PowerShell Toolmaking in a Month of Lunches and modified. Thanks Don Jones!
    [CmdletBinding()]
    
    param(
        [Parameter(Mandatory=$True)]
        [string[]]$ComputerName
    )

    BEGIN {
        $outputObj = $null
        $outputObj = @()
    }

    PROCESS {
        foreach ($computer in $computerName) {
            $tempObj = $null
            $tempObj = New-Object -TypeName PSObject

            $params = @{
                'computerName'=$computer
                'class'='Win32_OperatingSystem'
            }

            $os = Get-WmiObject @params

            $params = @{
                'computerName'=$computer;
                'class'='Win32_LogicalDisk';
                'filter'='drivetype=3'
            }
            
            $disks = Get-WmiObject @params
            
            $diskobjs = @()
            foreach ($disk in $disks) {
                $diskprops = @{
                    'Drive'=$disk.DeviceID;
                    'Size'="$(($disk.size / 1gb).ToString('#.##')) GB";
                    'FreeSpace'="$(($disk.FreeSpace / 1gb).ToString('#.##')) GB"
                }
                $diskobj = New-Object -Type PSObject -Property $diskprops
                $diskobjs += $diskobj
            }

            $ip = Test-Connection -ComputerName $os.PSComputerName -Count 1
            $pageFile = Get-WmiObject Win32_PageFileusage

            $tempObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $os.PSComputerName
            $tempObj | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $os.Caption
            $tempObj | Add-Member -MemberType NoteProperty -Name IPV4Address -Value $ip.IPV4Address
            $tempObj | Add-Member -MemberType NoteProperty -Name IPV6Address -Value $ip.IPV6Address
            $tempObj | Add-Member -MemberType NoteProperty -Name Disks -Value $diskobj
            $tempObj | Add-Member -MemberType NoteProperty -Name PageFile -Value "$(($pageFile.AllocatedBaseSize / 1kb).ToString('#.##')) MB"
            $outputObj += $tempObj
        }
    }

    END {
            Write-Output $outputObj
        }
}
