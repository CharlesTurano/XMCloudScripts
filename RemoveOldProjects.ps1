param([datetime] $removeBefore)

Import-Module .\xmcloud.psm1

$projects = Get-XMCProjects
foreach($project in $projects) {
    if ((Get-Date $project.createdAt) -le $removeBefore) {
        Write-Host "Found project $($project.name) with id $($project.id) created on $(Get-Date $project.createdAt)"

        Select-XMCProject -ProjectId $project.id | Out-Null

        foreach($environment in $project.environments) {
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
