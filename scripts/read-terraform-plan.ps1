

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

        $actionLabels = @{
            "CREATE" = "1. CREATE"
            "UPDATE" = "2. UPDATE"
            "DELETE" = "3. DELETE"
        }

        foreach ($key in $actionLabels.Keys | Sort-Object) {
            $filtered = $results | Where-Object { $_.Action -eq $key }
            if ($filtered) {
                Write-Host "`n$($actionLabels[$key]):" -ForegroundColor Cyan
                $filtered | Format-Table -AutoSize
            }
        }


    }
    catch {
        Write-Host "Error reading or parsing the file: $_" -ForegroundColor Red
        Exit 1
    }
}
