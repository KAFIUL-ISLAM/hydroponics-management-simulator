[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$GodotPath,

    [switch]$Import
)

$ErrorActionPreference = 'Stop'
try {
    $engine = (Resolve-Path -LiteralPath $GodotPath).Path
    if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) {
        throw "GodotPath must point to the Godot executable: $engine"
    }
    $projectPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
    $logDir = Join-Path ([IO.Path]::GetTempPath()) ("hydroponics-tests-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $logDir | Out-Null

    function Invoke-Godot([string]$Name, [string[]]$EngineArgs) {
        # Windows PowerShell can wrap native stderr in ErrorRecord objects.
        $ErrorActionPreference = 'Continue'
        $logPath = Join-Path $logDir "$Name.log"
        $lines = @(& $engine --headless --path $projectPath --log-file $logPath @EngineArgs 2>&1 | ForEach-Object { "$_" })
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Lines = $lines }
    }

    function Get-UnexpectedErrors($Run, [switch]$DuringImport) {
        foreach ($line in $Run.Lines) {
            if ($line -match '^ERROR: Failed to read the root certificate store\.\s*$') { continue }
            if ($DuringImport -and $line -match '^ERROR: (Cannot save file|Error saving editor settings to ).*editor_settings-[^/\\]+\.tres') { continue }
            if ($line -match '^(SCRIPT ERROR|ERROR):|Parse Error|_CHECK_FAILED:|Assertion failed') {
                $line
            }
        }
    }

    $cacheFiles = @(
        (Join-Path $projectPath '.godot/global_script_class_cache.cfg'),
        (Join-Path $projectPath '.godot/uid_cache.bin')
    )
    $missingCache = @($cacheFiles | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
    if ($Import -or $missingCache.Count -gt 0) {
        $importRun = Invoke-Godot 'import' @('--editor', '--import')
        $importErrors = @(Get-UnexpectedErrors $importRun -DuringImport)
        $missingCache = @($cacheFiles | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
        if ($importRun.ExitCode -ne 0 -or $importErrors.Count -gt 0 -or $missingCache.Count -gt 0) {
            $importErrors | ForEach-Object { Write-Host "  $_" }
            throw "Godot import failed (exit $($importRun.ExitCode)). Logs: $logDir"
        }
        Write-Host 'PASS  Godot project import'
    }

    $suites = @(
        @{ Name = 'Crop resource'; Scene = 'test_crop_resource'; Markers = @(
            '(?m)^TEST 1 PASSED:', '(?m)^TEST 2 PASSED:', '(?m)^TEST 3 PASSED:', '(?m)^TEST 4 PASSED:',
            '(?m)^========== ALL TESTS PASSED ==========\s*$'
        ) },
        @{ Name = 'Resource manager'; Scene = 'test_resource_manager'; Markers = @(
            '(?m)^RESOURCE_MANAGER_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Night state'; Scene = 'test_night_state'; Markers = @(
            '(?m)^NIGHT_STATE_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Dashboard startup'; Scene = 'test_main_dashboard'; Markers = @(
            '(?m)^DASHBOARD_STARTUP_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Workstations'; Scene = 'test_workstations'; Markers = @(
            '(?m)^WORKSTATIONS_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Environment interface'; Scene = 'test_environment_ui'; Markers = @(
            '(?m)^ENVIRONMENT_UI_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Orbital artwork'; Scene = 'test_orbital_art'; Markers = @(
            '(?m)^ORBITAL_ART_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Presentation'; Scene = 'test_presentation'; Markers = @(
            '(?m)^PRESENTATION_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'DNA editor'; Scene = 'test_dna_editor'; Markers = @(
            '(?m)^DNA_EDITOR_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Equipment'; Scene = 'test_equipment'; Markers = @(
            '(?m)^EQUIPMENT_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Seed reproduction'; Scene = 'test_seed_reproduction'; Markers = @(
            '(?m)^REPRODUCTION_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Genetics'; Scene = 'test_genetics'; Markers = @(
            '(?m)^GENETICS_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Pollution'; Scene = 'test_pollution'; Markers = @(
            '(?m)^POLLUTION_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Three crop farming'; Scene = 'test_three_crops'; Markers = @(
            '(?m)^THREE_CROP_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Coffee farming'; Scene = 'test_coffee_farm'; Markers = @(
            '(?m)^COFFEE_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Liquid composition'; Scene = 'test_liquid_composition'; Markers = @(
            '(?m)^LIQUID_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) },
        @{ Name = 'Nightly integration'; Scene = 'test_nightly_integration'; Markers = @(
            '(?m)^NIGHTLY_INTEGRATION_TEST_RESULT checks=[1-9]\d* failures=0\s*$'
        ) }
    )

    $passed = 0
    foreach ($suite in $suites) {
        $scene = $suite.Scene
        if (-not (Test-Path -LiteralPath (Join-Path $projectPath "tests/$scene.tscn") -PathType Leaf)) {
            Write-Host "FAIL  $($suite.Name) (scene missing)"
            continue
        }
        $run = Invoke-Godot $scene @('--debug', '--quit-after', '120', "res://tests/$scene.tscn")
        $outputText = $run.Lines -join "`n"
        $missing = @($suite.Markers | Where-Object { $outputText -notmatch $_ })
        $errors = @(Get-UnexpectedErrors $run)
        if ($run.ExitCode -eq 0 -and $missing.Count -eq 0 -and $errors.Count -eq 0) {
            $passed++
            Write-Host "PASS  $($suite.Name)"
        } else {
            Write-Host "FAIL  $($suite.Name) (exit $($run.ExitCode), missing markers $($missing.Count), unexpected errors $($errors.Count))"
            $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
        }
    }

    Write-Host "$passed/$($suites.Count) suites passed. Logs: $logDir"
    if ($passed -ne $suites.Count) { exit 1 }
    exit 0
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
