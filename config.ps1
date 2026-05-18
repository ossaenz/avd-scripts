# Create a new registry property to disable Teams auto-update
#New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name "disableAutoUpdate" -PropertyType DWORD -Value 1 -Force
# Set Delayed Desktop Switch Timeout
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DelayedDesktopSwitchTimeout" -Value 1 -PropertyType DWORD -Force

# Specify the registry path for Terminal Services
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"

# Define a hashtable with the registry values
$registryValues = @{
    "KeepAliveEnable" = 1
    "KeepAliveInterval" = 1
    "fEnableTimeZoneRedirection" = 1
    "Shadow" = 2
    "MaxDisconnectionTime" = 4500000
    "MaxConnectionTime" = 43200000
    "RemoteAppLogoffTimeLimit" = 4500000
    "MaxIdleTime" = 4500000
    "fResetBroken" = 1
}

# Create or update the registry values
foreach ($name in $registryValues.Keys) {
    $value = $registryValues[$name]
    Set-ItemProperty -Path $registryPath -Name $name -Value $value -Force
}

# Create the registry key for FSLogix if it doesn't exist
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Apps" -Name "CleanupInvalidSessions" -PropertyType DWORD -Value 1 -Force
Remove-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -Force
$regPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}

#CacheDirectory Configuration
if (Test-Path "D:\") {
    New-Item -Path "D:\FSLogix\Cache" -ItemType Directory -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\frxccd\Parameters" -Name "CacheDirectory" -PropertyType String -Value "D:\FSLogix\Cache" -Force
    #WriteCacheDirectory Configuration
    New-Item -Path "D:\FSLogix\WriteCache" -ItemType Directory -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\frxccds\Parameters" -Name "WriteCacheDirectory" -PropertyType String -Value "D:\FSLogix\WriteCache" -Force
    Write-Host "✅ FSLogix cache directories configured on D: drive" -ForegroundColor Green
} else {
    Write-Host "⚠️ D: drive not found - skipping FSLogix cache directory configuration" -ForegroundColor Yellow
}

# Define the registry values for FSLogix
$registryValues = @{
    "Enabled" = 1
    "DeleteLocalProfileWhenVHDShouldApply" = 1
    "CCDLocations" = "type=smb,connectionString=\\steusveelab01.file.core.windows.net\userprofiles;type=smb,connectionString=\\stwusveelab01.file.core.windows.net\userprofiles"
    "FlipFlopProfileDirectoryName" = 1
    "VolumeType" = "VHDX"
    "ClearCacheOnLogoff" = 1
    "ClearCacheOnForcedUnregister" = 1
    "CCDUnregisterTimeout" = 60
    "RedirXMLSourceFolder" = "\\steusveelab01.file.core.windows.net\userprofiles"
    "IsDynamic" = 1
    "AccessNetworkAsComputerObject" = 0
    "SizeInMBs" = 45000
    "ProfileType" = 0
}

# Set the registry values for FSLogix
$registryValues.GetEnumerator() | ForEach-Object {
    Set-ItemProperty -Path $regPath -Name $_.Key -Value $_.Value -Force
}
choco install greenshot -y
