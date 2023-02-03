##############################
#    AVD Script Parameters   #
##############################
Param (       
        [string]$ProfilePath,
    [Parameter(Mandatory=$true)]
        [string]$RegistrationToken          
)

######################
#    AVD Variables   #
######################
$LocalAVDpath            = "c:\temp\"
$AVDBootURI              = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$AVDAgentURI             = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$AVDAgentInstaller       = 'AVD-Agent.msi'
$AVDBootInstaller        = 'AVD-Bootloader.msi'

####################################
#    Test/Create Temp Directory    #
####################################
if((Test-Path c:\temp) -eq $false) {
    Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Create C:\temp Directory"
    Write-Host `
        -ForegroundColor Cyan `
        -BackgroundColor Black `
        "creating temp directory"
    New-Item -Path c:\temp -ItemType Directory
}
else {
    Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "C:\temp Already Exists"
    Write-Host `
        -ForegroundColor Yellow `
        -BackgroundColor Black `
        "temp directory already exists"
}
New-Item -Path c:\temp\ -Name New-AVDSessionHost.log -ItemType File
Add-Content `
-LiteralPath C:\temp\New-AVDSessionHost.log `
"
RegistrationToken = $RegistrationToken
"
#################################
#    Download AVD bits    #
#################################
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Downloading WVD Boot Loader"
    Invoke-WebRequest -Uri $AVDBootURI -OutFile "$LocalAVDpath$AVDBootInstaller"
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Downloading WVD Agent"
    Invoke-WebRequest -Uri $AVDAgentURI -OutFile "$LocalAVDpath$AVDAgentInstaller"

################################
#    Install WVD Componants    #
################################
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Installing AVD Bootloader"
$bootloader_deploy_status = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList "/i $AVDBootInstaller", `
        "/quiet", `
        "/qn", `
        "/norestart", `
        "/passive", `
        "/l* $LocalAVDpath\AgentBootLoaderInstall.txt" `
    -Wait `
    -Passthru
$sts = $bootloader_deploy_status.ExitCode
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Installing AVD Bootloader Complete"
Write-Output "Installing RDAgentBootLoader on VM Complete. Exit code=$sts`n"
Wait-Event -Timeout 5
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Installing AVD Agent"
Write-Output "Installing RD Infra Agent on VM $AgentInstaller`n"
$agent_deploy_status = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList "/i $AVDAgentInstaller", `
        "/quiet", `
        "/qn", `
        "/norestart", `
        "/passive", `
        "REGISTRATIONTOKEN=$RegistrationToken", "/l* $LocalAVDpath\AgentInstall.txt" `
    -Wait `
    -Passthru
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "WVD Agent Install Complete"
Wait-Event -Timeout 5
##########################
#    Restart Computer    #
##########################
Add-Content -LiteralPath C:\temp\New-AVDSessionHost.log "Process Complete - REBOOT"
Restart-Computer -Force 
