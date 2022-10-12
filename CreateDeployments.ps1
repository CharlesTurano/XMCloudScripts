param([string] $prefix="SYM", [int] $NumberOfDeployments)

Import-Module .\xmcloud.psm1

cloud login

$currentLocation = Get-Location

$procs = @()

for ($count = 0; $count -lt $NumberOfDeployments; $count++) {
    $environmentName = "TestEnvironment_$count"
    $newProjectName = "$($prefix)_$count"
    
    $procs += Start-Process -PassThru powershell -NoNewWindow -Args "$currentLocation\StartDeployment.ps1 -Name $environmentName -ProjectName $newProjectName"
}

foreach($proc in $procs) {
    $procs.WaitForExit()
}