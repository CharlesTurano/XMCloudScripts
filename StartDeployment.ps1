param ($Name, $ProjectName)

Import-Module .\xmcloud.psm1

$project = Select-XMCProject -projectName $ProjectName

if (-not $project) {
    Write-host "Creating project $ProjectName"

    $project = New-XMCProject -name $projectName
}

$environment = Select-XMCEnvironment -environmentName $Name

if (-not $environment) {
    Write-Host "Creating environment $name"

    $environment = New-XMCEnvironment -name $Name
}

$deployment = New-XMCDeployment -upload

if (-not $deployment) {
    Write-Host "Deployment already running"
} else {
    Write-Host "Started deployment $($deployment.id) in environment $($environment.id)"

    $currentLocation = Get-Location

    Start-Process -FilePath "powershell" -Args "-Command & {`$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(70,10); Import-Module $currentLocation\xmcloud.psm1; Show-XMCDeployment -deploymentId $($deployment.Id); Read-Host}" 
}