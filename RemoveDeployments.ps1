param([string] $prefix="SYM", [int] $NumberOfDeployments)

Import-Module .\xmcloud.psm1

$projects = Get-XMCProjects
foreach($project in $projects) {
    if ($project.name.StartsWith($prefix, "CurrentCultureIgnoreCase")) {
        Write-Host "Found project $($project.name) with id $($project.id)"

        Select-XMCProject -ProjectId $project.id | Out-Null
        $environments = Get-XMCEnvironments

        foreach($environment in $environments) {
            Write-Host "  Found environment $($environment.name) with id $($environment.id)"
            
            Select-XMCEnvironment -environmentId $environment.id | Out-Null
            $deployments = Get-XMCDeployments
            foreach($deployment in $deployments) {
                Write-host "    Found Deployment $($deployment.id)"

                if ($deployment.calculatedStatus -eq 1 -or $deployment.calculatedStatus -eq 0) {
                    Write-Host "    Stopping deployment $($deployment.id)"
                    Stop-XmcDeployment -deploymentId $deployment.id
                }
            }

            Remove-XMCEnvironment -force
            Write-Host "Removed environment $($environment.Name)"
        }

        Remove-XMCProject -force
        Write-Host "Removed project $($project.name)"
    }
}