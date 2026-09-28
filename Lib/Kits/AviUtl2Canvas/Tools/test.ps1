param([switch]$UI)
$ErrorActionPreference = 'Stop'
$kitRoot = Split-Path $PSScriptRoot -Parent
$setup = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat'
Push-Location (Join-Path $kitRoot 'Tests')
try {
    New-Item -ItemType Directory -Force -Path 'Win64\Tests' | Out-Null
    $buildLine = 'call "' + $setup + '" && dcc64 -B -Q -U"..\Source\Host;..\Source\UI" -E"Win64\Tests" -N0"Win64\Tests" CanvasTests.dpr'
    & $env:ComSpec /d /s /c $buildLine
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($UI) { & '.\Win64\Tests\CanvasTests.exe' --ui } else { & '.\Win64\Tests\CanvasTests.exe' }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally { Pop-Location }
