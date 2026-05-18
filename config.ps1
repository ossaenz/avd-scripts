# Session Host Configuration Script
# Requires: FSLogix installed, Chocolatey installed, D: drive (optional)

#region Terminal Services
$tsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
@{
    KeepAliveEnable            = 1
    KeepAliveInterval          = 1
    fEnableTimeZoneRedirection = 1
    Shadow                     = 2
    MaxDisconnectionTime       = 4500000
    MaxConnectionTime          = 43200000
    RemoteAppLogoffTimeLimit   = 4500000
    MaxIdleTime                = 4500000
    fResetBroken               = 1
}.GetEnumerator() | ForEach-Object { Set-ItemProperty -Path $tsPath -Name $_.Key -Value $_.Value -Force }

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DelayedDesktopSwitchTimeout" -Value 1 -Force
#endregion

#region FSLogix
Remove-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Apps" -Name "CleanupInvalidSessions" -PropertyType DWORD -Value 1 -Force | Out-Null

$flPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
if (-not (Test-Path $flPath)) { New-Item -Path $flPath -Force | Out-Null }

@{
    Enabled                          = 1
    DeleteLocalProfileWhenVHDShouldApply = 1
    CCDLocations                     = "type=smb,connectionString=\\steusveelab01.file.core.windows.net\userprofiles;type=smb,connectionString=\\stwusveelab01.file.core.windows.net\userprofiles"
    FlipFlopProfileDirectoryName     = 1
    VolumeType                       = "VHDX"
    ClearCacheOnLogoff               = 1
    ClearCacheOnForcedUnregister     = 1
    CCDUnregisterTimeout             = 60
    RedirXMLSourceFolder             = "\\steusveelab01.file.core.windows.net\userprofiles"
    IsDynamic                        = 1
    AccessNetworkAsComputerObject    = 0
    SizeInMBs                        = 45000
    ProfileType                      = 0
}.GetEnumerator() | ForEach-Object { Set-ItemProperty -Path $flPath -Name $_.Key -Value $_.Value -Force }
#endregion

#region FSLogix Cache (D: drive)
if (Test-Path "D:\") {
    @{ "frxccd\Parameters"  = "D:\FSLogix\Cache"
       "frxccds\Parameters" = "D:\FSLogix\WriteCache" }.GetEnumerator() | ForEach-Object {
        New-Item -Path "D:\FSLogix\$($_.Key -replace '\\Parameters','')" -ItemType Directory -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($_.Key)" -Name "$(if ($_.Key -match 'frxccds') { 'WriteCacheDirectory' } else { 'CacheDirectory' })" -PropertyType String -Value $_.Value -Force | Out-Null
    }
}
#endregion

#region Apps
choco install greenshot -y
#endregion
