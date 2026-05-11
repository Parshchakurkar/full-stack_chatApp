param (
    [string]$tfplanFolder
)

function readLogs {
    param (
        [string]$file
    )
    try {
        $plan = Get-Content -Path $file | ConvertFrom-Json

        $results = foreach ($change in $plan.resource_changes) {
            [PSCustomObject]@{
                Resource      = $change.address
                Type          = $change.type
                Action        = ($change.change.actions -join "+").ToUpper()
                ResourceGroup = $change.change.after.resource_group_name ?? $change.change.before.resource_group_name
                SKU           = $change.change.after.sku ?? $change.change.before.sku
            }
        }

        # Desired display order for common actions
        $orderedKeys = @("CREATE", "UPDATE", "DELETE")

        $actionLabels = @{
            "CREATE" = "1. CREATE"
            "UPDATE" = "2. UPDATE"
            "DELETE" = "3. DELETE"
        }

        $printed = @()

        # Print common actions in the desired order
        foreach ($key in $orderedKeys) {
            $filtered = $results | Where-Object { $_.Action -eq $key }
            if ($filtered) {
                Write-Host "`n$($actionLabels[$key]):" -ForegroundColor Cyan
                $filtered | Format-Table -AutoSize
                $printed += $key
            }
        }

        # Find any other distinct action values and print them grouped under OTHER
        $allActions = $results.Action | Where-Object { $_ -ne $null } | Sort-Object -Unique
        $otherActions = $allActions | Where-Object { -not ($printed -contains $_) }
        if ($otherActions) {
            foreach ($act in $otherActions) {
                Write-Host "`nOTHER - $act :" -ForegroundColor Yellow
                $filtered = $results | Where-Object { $_.Action -eq $act }
                $filtered | Format-Table -AutoSize
            }
        }


    }
    catch {
        Write-Host "Error reading or parsing the file: $_" -ForegroundColor Red
        Exit 1
    }
}

#Convert .tfplan in json format

function tfplanToJson {
    param (
        [string]$tfplanFolder
    )
    try {
        if (Test-Path -path $tfplanFolder/tfplan.binary) {
            terraform show -json $tfplanFolder/tfplan.binary > $tfplanFolder/plan.json
            readLogs -file $tfplanFolder/plan.json
        }
        else {
            Write-Host "The specified .tfplan file does not exist in: $tfplanFolder" -ForegroundColor Red
            Exit 1
        }
    }
    catch {
        Write-Host "Error converting .tfplan to JSON: $_" -ForegroundColor Red
        Exit 1
    }
}



#------------------Eexecution------------------
tfplanToJson -tfplanFolder $tfplanFolder
