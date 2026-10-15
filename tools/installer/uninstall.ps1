param([string]$ResultFile)

$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $resultFile = Join-Path ([System.IO.Path]::GetTempPath()) ("jm-uninstall-result-" + [guid]::NewGuid().ToString('N') + '.txt')
    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ResultFile `"$resultFile`""
        $process = Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -ArgumentList $arguments -Wait -PassThru
        if (Test-Path -LiteralPath $resultFile) {
            [Console]::Out.WriteLine([System.IO.File]::ReadAllText($resultFile).TrimEnd())
        } elseif ($process.ExitCode -ne 0) {
            [Console]::Error.WriteLine("jm uninstallation failed (exit code $($process.ExitCode)).")
        }
        exit $process.ExitCode
    }
    catch {
        [Console]::Error.WriteLine("jm uninstallation was cancelled or failed: $($_.Exception.Message)")
        exit 1
    }
    finally {
        Remove-Item -LiteralPath $resultFile -Force -ErrorAction SilentlyContinue
    }
}

try {
    if (-not $env:ProgramFiles) { throw 'ProgramFiles is not set.' }
    if (-not $env:LOCALAPPDATA) { throw 'LOCALAPPDATA is not set.' }
    $installDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:ProgramFiles 'main\jm'))
    $previousInstallDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:ProgramFiles 'VolunteerHub\jm'))
    $legacyDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'VolunteerHub\jm'))
    $userInstallDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'main\jm'))

    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($machinePath) {
        $machineEntries = @($machinePath -split ';' | Where-Object {
            $_ -and -not [string]::Equals($_.TrimEnd('\'), $installDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) -and
                -not [string]::Equals($_.TrimEnd('\'), $previousInstallDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
        })
        [Environment]::SetEnvironmentVariable('Path', ($machineEntries -join ';'), 'Machine')
    }
    $machineJmHome = [Environment]::GetEnvironmentVariable('JM_HOME', 'Machine')
    if (([string]::Equals($machineJmHome, $installDirectory, [StringComparison]::OrdinalIgnoreCase) -or
        [string]::Equals($machineJmHome, $previousInstallDirectory, [StringComparison]::OrdinalIgnoreCase))) {
        [Environment]::SetEnvironmentVariable('JM_HOME', $null, 'Machine')
    }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath) {
        $userEntries = @($userPath -split ';' | Where-Object {
            $_ -and -not [string]::Equals($_.TrimEnd('\'), $legacyDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) -and
            -not [string]::Equals($_.TrimEnd('\'), $userInstallDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
        })
        [Environment]::SetEnvironmentVariable('Path', ($userEntries -join ';'), 'User')
    }
    $userJmHome = [Environment]::GetEnvironmentVariable('JM_HOME', 'User')
    if ([string]::Equals($userJmHome, $legacyDirectory, [StringComparison]::OrdinalIgnoreCase) -or
        [string]::Equals($userJmHome, $userInstallDirectory, [StringComparison]::OrdinalIgnoreCase)) {
        [Environment]::SetEnvironmentVariable('JM_HOME', $null, 'User')
    }

    foreach ($directory in @($installDirectory, $previousInstallDirectory, $legacyDirectory, $userInstallDirectory)) {
        if (Test-Path -LiteralPath $directory) {
            Remove-Item -LiteralPath $directory -Recurse -Force
        }
    }

    $message = "Uninstalled successfully from $installDirectory"
    if ($ResultFile) {
        [System.IO.File]::WriteAllText($ResultFile, $message)
    } else {
        [Console]::Out.WriteLine($message)
    }
}
catch {
    $message = "jm uninstallation failed: $($_.Exception.Message)"
    if ($ResultFile) {
        [System.IO.File]::WriteAllText($ResultFile, $message)
    } else {
        [Console]::Error.WriteLine($message)
    }
    exit 1
}