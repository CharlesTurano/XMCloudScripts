function runCloud { dotnet sitecore cloud $args }
Set-Alias -n cloud runCloud
function runSitecore { dotnet sitecore $args }
Set-Alias -n sitecore runSitecore

#region Project Functions
function Get-XMCProjects {
    param ([switch] $table)

    if ($table) {
        cloud project list --json | 
        ConvertFrom-Json | 
        Sort-Object -property createdat | 
        Format-Table -autosize -property id,name,createdat
    }
    else {
        cloud project list --json | ConvertFrom-Json
    }
}

function New-XMCProject {   
    param([String] $name)

    $project = cloud project create -n $name --json | ConvertFrom-Json

    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    $env:XMC_Current_Project = $project.id
        
    $project
}

function Get-XMCProjectInfo {
    param([string] $projectId)

    if ($projectId) {
        $env:XMC_Current_Project = $projectId
    }
    else {
        $projectId = $env:XMC_Current_Project
    }

    cloud project info -id $projectId --json | ConvertFrom-Json
}

function Remove-XMCProject {
    param([string] $projectId, [switch] $force)

    if ($projectId) {
        $env:XMC_Current_Project = $projectId
    }
    else {
        $projectId = $env:XMC_Current_Project
    }

    $forceParam = ""
    if ($force) {
        $forceParam = "--force"
    }

    cloud project delete $forceParam -id $projectId

    if ($LASTEXITCODE -eq 0) {
        remove-item env:XMC_Current_Project
    }
}

function Select-XMCProject {
    param([string] $projectName, [string] $projectId)

    if ($projectId) {
        $env:XMC_Current_Project = $projectId
    }

    if ($projectName) {
        $projects = cloud project list --json | ConvertFrom-Json
        $selectedProject = $projects | Where-Object -Property name -eq $projectName

        if (-not $selectedProject) {
            return $null
        }

        $env:XMC_Current_Project = $selectedProject.id
    }

    cloud project info -id $env:XMC_Current_Project --json | ConvertFrom-Json
}
#endregion

#region Environment Functions
function Get-XMCEnvironments{
    param([string]$projectId, [switch] $table)

    if (-not $projectId) {
        $projectId = $env:XMC_Current_Project
    }

    if ($table) {
        cloud environment list --project-id $projectId --json |
        ConvertFrom-Json | 
        Sort-Object -property createdat | 
        Format-Table -autosize -property id,name,host,provisioningStatus,createdat
    } else {
        cloud environment list --project-id $projectId --json |
        ConvertFrom-Json        
    }
}

function New-XMCEnvironment {
    param([String] $name, [String] $projectId)

    if (-not $projectId) {
        $projectId = $env:XMC_Current_Project
    }

    $environment = cloud environment create --project-id $projectId -n $name --json | ConvertFrom-Json

    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    $env:XMC_Current_Environment = $environment.id
        
    $environment
}

function Get-XMCEnvironmentInfo {
    param([string] $environmentId)

    if ($environmentId) {
        $env:XMC_Current_Environment = $environmentId
    }
    else {
        $environmentId = $env:XMC_Current_Environment
    }

    cloud environment info -id $environmentId --json | ConvertFrom-Json
}

function Remove-XMCEnvironment {
    param([string] $environmentId, [switch] $force)

    if ($environmentId) {
        $env:XMC_Current_Environment = $environmentId
    }
    else {
        $environmentId = $env:XMC_Current_Environment
    }

    $forceParam = ""
    if ($force) {
        $forceParam = "--force"
    }

    cloud environment delete $forceParam -id $environmentId

    if ($LASTEXITCODE -eq 0) {
        remove-item env:XMC_Current_Environment
    }
}

function Select-XMCEnvironment {
    param([string] $environmentName, [string] $environmentId)

    if ($environmentId) {
        $env:XMC_Current_Environment = $environmentId
    }

    if ($environmentName) {
        $environments = cloud environment list --project-id $env:XMC_Current_Project --json | ConvertFrom-Json
        $selectedEnvironment = $environments | Where-Object -Property name -eq $environmentName

        if (-not $selectedEnvironment) {
            return $null
        }

        $env:XMC_Current_Environment = $selectedEnvironment.id
    }

    cloud environment info -id $env:XMC_Current_Environment --json | ConvertFrom-Json
}

function Connect-XMCEnvironment {
    param([string] $environmentId)

    if ($environmentId) {
        $env:XMC_Current_Environment = $environmentId
    }
    else {
        $environmentId = $env:XMC_Current_Environment
    }

    cloud environment connect -id $environmentId -aw
}

function Disconnect-XMCEnvironment {
    param([string] $environmentId)

    if ($environmentId) {
        $env:XMC_Current_Environment = $environmentId
    }
    else {
        $environmentId = $env:XMC_Current_Environment
    }

    cloud environment disconnect -id $environmentId
}

#endregion

#region Deployment functions
function Get-XMCDeployments{
    param([string]$environmentId, [switch] $table)

    if (-not $environmentId) {
        $environmentId = $env:XMC_Current_Environment
    }

    if ($table) {
        cloud deployment list --environment-id $environmentId --json |
        ConvertFrom-Json | 
        Sort-Object -property createdat | 
        Format-Table -autosize -property id,createdAt, calculatedStatus, provisioningStatus, buildStatus, deploymentStatus, postActionStatus
    } else {
        cloud deployment list --environment-id $environmentId --json |
        ConvertFrom-Json
    }
}

function New-XMCDeployment {
    param([string]$environmentId, [switch] $upload, [switch] $NoStart)

    if (-not $environmentId) {
        $environmentId = $env:XMC_Current_Environment
    }

    $startParam = ""

    if ($NoStart) {
        $startParam = "--no-start"
    }
    
    $uploadParam = ""

    if ($upload) {
        $uploadParam = "--upload"
    }

    $deployment = cloud deployment create --environment-id $environmentId $startParam $uploadParam --no-watch --json | ConvertFrom-Json

    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    $env:XMC_Current_Deployment = $deployment.id

    $deployment
}

function Show-XMCDeployment {
    param([string]$deploymentId)

    if (-not $deploymentId) {
        $deploymentId = $env:XMC_Current_Deployment
    }

    cloud deployment watch -id $deploymentId
}

function Get-XMCDeploymentInfo {
    param([string] $deploymentId)

    if ($deploymentId) {
        $env:XMC_Current_Deployment = $deploymentId
    }
    else {
        $deploymentId = $env:XMC_Current_Deployment
    }

    cloud deployment info -id $deploymentId --json | ConvertFrom-Json
}

function Start-XMCDeployment {
    param([string] $deploymentId)

    if ($deploymentId) {
        $env:XMC_Current_Deployment = $deploymentId
    }
    else {
        $deploymentId = $env:XMC_Current_Deployment
    }

    cloud deployment start -id $deploymentId --no-watch --json | ConvertFrom-Json
}

function Stop-XMCDeployment {
    param([string] $deploymentId)

    if ($deploymentId) {
        $env:XMC_Current_Deployment = $deploymentId
    }
    else {
        $deploymentId = $env:XMC_Current_Deployment
    }

    cloud deployment cancel -id $deploymentId
}

function Select-XMCDeployment {
    param([string] $deploymentId)

    if ($deploymentId) {
        $env:XMC_Current_Deployment = $deploymentId
    } else {
        $selectedDeployment = (cloud deployment list --environment-id $env:XMC_Current_Environment --json | ConvertFrom-Json) | Select-Object -Last 1

        if (-not $selectedDeployment) {
            return $null
        }

        $env:XMC_Current_Deployment = $selectedDeployment.id
    }

    cloud deployment info -id $env:XMC_Current_Deployment --json | ConvertFrom-Json
}
#endregion

Export-ModuleMember -Alias Cloud
Export-ModuleMember -Alias Sitecore
Export-ModuleMember -Function Get-XMCProjects
Export-ModuleMember -Function New-XMCProject
Export-ModuleMember -Function Get-XMCProjectInfo
Export-ModuleMember -Function Remove-XMCProject
Export-ModuleMember -Function Select-XMCProject

Export-ModuleMember -Function Get-XMCEnvironments
Export-ModuleMember -Function New-XMCEnvironment
Export-ModuleMember -Function Get-XMCEnvironmentInfo
Export-ModuleMember -Function Remove-XMCEnvironment
Export-ModuleMember -Function Select-XMCEnvironment
Export-ModuleMember -Function Connect-XMCEnvironment
Export-ModuleMember -Function Disconnect-XMCEnvironment

Export-ModuleMember -Function Get-XMCDeployments
Export-ModuleMember -Function New-XMCDeployment
Export-ModuleMember -Function Show-XMCDeployment
Export-ModuleMember -Function Get-XMCDeploymentInfo
Export-ModuleMember -Function Start-XMCDeployment
Export-ModuleMember -Function Stop-XMCDeployment
Export-ModuleMember -Function Select-XMCDeployment