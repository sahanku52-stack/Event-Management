param([string]$ResultFile)

$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $resultFile = Join-Path ([System.IO.Path]::GetTempPath()) ("jm-install-result-" + [guid]::NewGuid().ToString('N') + '.txt')
    try {
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ResultFile `"$resultFile`""
        $process = Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -ArgumentList $arguments -Wait -PassThru
        if (Test-Path -LiteralPath $resultFile) {
            [Console]::Out.WriteLine([System.IO.File]::ReadAllText($resultFile).TrimEnd())
        } elseif ($process.ExitCode -ne 0) {
            [Console]::Error.WriteLine("jm installation failed (exit code $($process.ExitCode)).")
        }
        exit $process.ExitCode
    }
    catch {
        [Console]::Error.WriteLine("jm installation was cancelled or failed: $($_.Exception.Message)")
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
    $previousMachineDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:ProgramFiles 'VolunteerHub\jm'))
    $legacyDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'VolunteerHub\jm'))
    $previousUserDirectory = [System.IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'main\jm'))
    $source = Join-Path $PSScriptRoot '..\jm\src\Jm.java'
    $classesDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("volunteer-jm-install-" + [guid]::NewGuid().ToString('N'))
    $jarPath = Join-Path $installDirectory 'jm.jar'

    foreach ($tool in @('javac', 'jar')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw 'JDK 11 or newer is required. Install a JDK and make sure javac and jar are on PATH.'
        }
    }

    New-Item -ItemType Directory -Path $classesDirectory | Out-Null
    New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
    try {
        & javac --release 11 -encoding UTF-8 -d $classesDirectory $source
        if ($LASTEXITCODE -ne 0) { throw "Could not compile jm (javac exit code $LASTEXITCODE)." }
        & jar --create --file $jarPath --main-class Jm -C $classesDirectory .
        if ($LASTEXITCODE -ne 0) { throw "Could not package jm (jar exit code $LASTEXITCODE)." }

        $launcher = Join-Path $installDirectory 'jm.cmd'
        @('@echo off', 'java -jar "%~dp0jm.jar" %*', 'exit /b %ERRORLEVEL%') |
            Set-Content -LiteralPath $launcher -Encoding Ascii

        [Environment]::SetEnvironmentVariable('JM_HOME', $installDirectory, 'Machine')
        $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        $pathEntries = @()
        if ($machinePath) { $pathEntries = @($machinePath -split ';' | Where-Object { $_ }) }
        $pathEntries = @($pathEntries | Where-Object {
            $entry = $_.TrimEnd('\')
            -not [string]::Equals($entry, $installDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) -and
                -not [string]::Equals($entry, $previousMachineDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
        })
        [Environment]::SetEnvironmentVariable('Path', (@($pathEntries) + $installDirectory) -join ';', 'Machine')

        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath) {
            $userEntries = @($userPath -split ';' | Where-Object {
                $_ -and -not [string]::Equals($_.TrimEnd('\'), $legacyDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase) -and
                    -not [string]::Equals($_.TrimEnd('\'), $previousUserDirectory.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
            })
            [Environment]::SetEnvironmentVariable('Path', ($userEntries -join ';'), 'User')
        }
        $userJmHome = [Environment]::GetEnvironmentVariable('JM_HOME', 'User')
        if ([string]::Equals($userJmHome, $legacyDirectory, [StringComparison]::OrdinalIgnoreCase) -or
            [string]::Equals($userJmHome, $previousUserDirectory, [StringComparison]::OrdinalIgnoreCase)) {
            [Environment]::SetEnvironmentVariable('JM_HOME', $null, 'User')
        }
        if (Test-Path -LiteralPath $previousMachineDirectory) {
            Remove-Item -LiteralPath $previousMachineDirectory -Recurse -Force
        }
        foreach ($oldUserDirectory in @($legacyDirectory, $previousUserDirectory)) {
            if (Test-Path -LiteralPath $oldUserDirectory) {
                Remove-Item -LiteralPath $oldUserDirectory -Recurse -Force
            }
        }
    }
    finally {
        Remove-Item -LiteralPath $classesDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }

    $message = "Installed successfully at $installDirectory"
    if ($ResultFile) {
        [System.IO.File]::WriteAllText($ResultFile, $message)
    } else {
        [Console]::Out.WriteLine($message)
    }
}
catch {
    $message = "jm installation failed: $($_.Exception.Message)"
    if ($ResultFile) {
        [System.IO.File]::WriteAllText($ResultFile, $message)
    } else {
        [Console]::Error.WriteLine($message)
    }
    exit 1
}