#PowerShell script that queries all servers in Active Directory, then checks if the current computer account has administrative privileges on each server


# Import Active Directory module
Import-Module ActiveDirectory

# Get the name of the current computer account
$currentComputerAccount = "$($env:COMPUTERNAME)$"
#$currentComputerAccount = "$<Any Server FQDN>"

# Get all servers (computers with Server OS) in Active Directory
$servers = Get-ADComputer -Filter {OperatingSystem -like "*Server*"} -Property OperatingSystem | Select-Object -ExpandProperty Name

# Output results
$results = @()

foreach ($server in $servers) {
    Write-Host "Checking server: $server" -ForegroundColor Yellow
    try {
        # Check if the current computer account has admin privileges
        $adminAccess = Test-Path "\\$server\Admin$"
        
        # Store the result
        $results += [PSCustomObject]@{
            ServerName     = $server
            AdminPrivilege = if ($adminAccess) { "Yes" } else { "No" }
        }
    } catch {
        # Handle any errors (e.g., server not reachable)
        $results += [PSCustomObject]@{
            ServerName     = $server
            AdminPrivilege = "Error: $_"
        }
    }
}

# Display results
$results | Format-Table -AutoSize

# Export results to a CSV file
$results | Export-Csv -Path "AdminPrivilegeCheckResults.csv" -NoTypeInformation

Write-Host "Check completed. Results saved to AdminPrivilegeCheckResults.csv" -ForegroundColor Green
