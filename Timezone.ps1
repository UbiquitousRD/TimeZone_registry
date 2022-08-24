    #NTPServer
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "NtpServer" -Value "time.windows.com,0x1" -Force -ErrorAction ignore
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Value "Allsync" -Force -ErrorAction ignore

    function Get-RegistryValue($path, $name)
    {
        $key = Get-Item -LiteralPath $path -ErrorAction ignoreS
        if ($key) {
            $key.GetValue($name, $null)
        }
    }

    #LocationConsentKey
    $LocationConsentValue = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value"
    if ($null -eq $LocationConsentValue)
    {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -PropertyType String -Value "Allow" -Force -ErrorAction ignore
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Allow" -Force -ErrorAction ignore
    }

    #SensorPermissionState
    $SensorPermissionState = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState"
    if ($null -eq $SensorPermissionState)
    {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -PropertyType Dword -Value 1 -Force -ErrorAction ignore
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Value 1 -Force -ErrorAction ignore
    }

    #TZAutoUpdate
    if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate")
    {
        $TZAutoUpdateValue = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start"
        if ($TZAutoUpdateValue -ne 3)
        {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3 -Force -ErrorAction ignore
        }
    }

    #lfsvc Registry
    $lfsvcValue = Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Configuration" "Status"
    if ($null -eq $lfsvcValue)
    {
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Configuration" -Name "Status" -PropertyType Dword -Value 1 -Force -ErrorAction ignore
    } else {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Configuration" -Name "Status" -Value 1 -Force -ErrorAction ignore
    }

    #LocationServices
    Restart-Service -Name "lfsvc" -Force -ErrorAction ignore
    $LocationService = Get-Service -Name "lfsvc"
    if ($LocationService.Status -notlike "Running") {
        Start-Service -Name "lfsvc" -ErrorAction ignore
    }

    #TimeServices
    Restart-Service -Name "Windows Time" -Force -ErrorAction ignore
    $TimeService = Get-Service -Name "Windows Time"
    if ($TimeService.Status -notlike "Running") {
        Start-Service -Name "Windows Time" -ErrorAction ignore
    }

    Write-Output "Successfully configured AutoTimeZone settings"
    exit 0