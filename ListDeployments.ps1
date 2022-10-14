param([string] $prefix="SYM")

Import-Module .\xmcloud.psm1

$projects = (Get-XMCProjects) | Where-Object name -like "$prefix*"
foreach($project in $projects) {
    Select-XMCProject -ProjectId $project.id | Out-Null
    foreach($environmentId in $project.environments) {
        $environment = Select-XMCEnvironment -environmentId $environmentId
        $deployments = Get-XMCDeployments
        foreach($deployment in $deployments) {
            Write-host "Found Deployment $($deployment.id) in $($project.name).$($environment.name) state is $($deployment.calculatedStatus)"
        }
    }
}
