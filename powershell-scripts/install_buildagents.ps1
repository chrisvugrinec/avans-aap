param
(
    $token,
    $poolname="bap-aap-tier1",
    $agentname="$env:COMPUTERNAME"
)

get-service | where displayname -match "pipline" |  % {& "sc.exe delete $_.name"} -ErrorAction Continue
Remove-Item c:\azuredevopsworkdir -Recurse -Force -ErrorAction Continue
Remove-Item c:\agent -Recurse -Force -ErrorAction Continue

new-item c:\azuredevopsworkdir -ItemType Directory
new-item c:\agent -ItemType Directory
cd c:\agent
$webClient = [System.Net.WebClient]::new()
$webClient.DownloadFile("https://vstsagentpackage.azureedge.net/agent/2.190.0/vsts-agent-win-x64-2.190.0.zip", "c:\agent\vsts-agent-win-x64-2.190.0.zip")
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\agent\vsts-agent-win-x64-2.190.0.zip", "$PWD")
$param="--unattended  --url https://dev.azure.com/Avansuas --auth pat --token $token --pool "+""""+"$poolname"+""""+" --agent $agentname --work c:\azuredevopsworkdir --runAsService --windowsLogonAccount 'nt authority\network service'"
Start-Process C:\agent\config.cmd -ArgumentList $param -PassThru 

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Continue
Register-PSRepository -Default -InstallationPolicy Trusted -ErrorAction Continue
Install-Module -Name AZ -Scope AllUsers -Force
Install-Module -Name Az.Subscription -RequiredVersion 0.7.3
# Install chocolately
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# Install terraform with choco
choco install terraform --force --yes


set-timezone -Id 'W. Europe Standard Time'
