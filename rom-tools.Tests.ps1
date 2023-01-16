BeforeAll {
    $DebugPreference = 'Continue'
    $modulePath = $PSCommandPath.Replace('.Tests.ps1', '.psm1')
    if (-not (Test-Path $modulePath)) {
        Write-Error "Could not find $modulePath"
    }        
    Import-Module $modulePath -Scope Local -ErrorAction Stop
}

Describe 'rom-tools' {
    It 'Returns expected output' {
        $lines = Get-Content .\sample-rom-dat-index.txt
        $infos = New-Object System.Collections.ArrayList
        $unmatchables = New-Object System.Collections.ArrayList
        foreach ($name in $lines) {
            # Write-Debug "Current item is `"$name`""
            try {
                $info = Get-InfoFromName $name
            }
            catch [System.FormatException] {
                Write-Warning "`n$($Error[0])`n"
                $unmatchables.Add($name)
                continue
            }
            $info | Should -Not -BeNullOrEmpty
            $infos.Add($info)
        }

        Write-Debug "Unmatchable names`n$($unmatchables | Out-String)"

        $infos | Format-Table -AutoSize -GroupBy Company | Out-String | Write-Debug
    }
}
