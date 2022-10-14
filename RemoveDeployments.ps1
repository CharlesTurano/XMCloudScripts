param([string] $prefix="SYM")

Import-Module .\xmcloud.psm1

$projects = (Get-XMCProjects) | Where-Object name -like "$prefix*"
foreach($project in $projects) {
    Write-Host "Found project $($project.name) with id $($project.id)"

    Select-XMCProject -ProjectId $project.id | Out-Null
    foreach($environment in $project.environments) {
        $environment = Select-XMCEnvironment -environmentId $environment
        Write-Host "  Found environment $($environment.name) with id $($environment.id)"
        
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
