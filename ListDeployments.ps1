param([string] $prefix="SYM", [int] $NumberOfDeployments)

Import-Module .\xmcloud.psm1

$projects = Get-XMCProjects
foreach($project in $projects) {
    if ($project.name.StartsWith($prefix, "CurrentCultureIgnoreCase")) {
        Select-XMCProject -ProjectId $project.id | Out-Null
        foreach($environmentId in $project.environments) {
            $environment=Select-XMCEnvironment -environmentId $environmentId
            $deployments = Get-XMCDeployments
            foreach($deployment in $deployments) {
                Write-host "Found Deployment $($deployment.id) in $($project.name).$($environment.name) state is $($deployment.calculatedStatus)"
            }
        }
    }
}
