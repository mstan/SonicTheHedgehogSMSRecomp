# build.ps1 — regenerate + build SonicTheHedgehogSMSRecomp (windowed) from your ROM.
#
# Requires:
#   - the smsggrecomp engine checked out as a sibling: ..\smsggrecomp
#     (built recompiler at ..\smsggrecomp\recompiler\build\SmsRecomp.exe)
#   - MinGW-w64 gcc + SDL2 dev libs (MSYS2 'mingw64' by default)
#   - your own legally-dumped ROM next to this script
#
# Usage:  powershell -File build.ps1 [-Rom sonicthehedgehog.sms] [-Sdl C:\msys64\mingw64]
param(
    [string]$Rom = "sonicthehedgehog.sms",
    [string]$Sdl = "C:\msys64\mingw64"
)
$ErrorActionPreference = "Stop"

$prefix = "sonic1sms"
$out    = "SonicTheHedgehogSMSRecomp.exe"
$engine = (Resolve-Path "..\smsggrecomp").Path
$recomp = Join-Path $engine "recompiler\build\SmsRecomp.exe"
$runner = Join-Path $engine "runner"
$gen    = Join-Path (Get-Location) "generated"

if (-not (Test-Path $Rom))    { throw "ROM '$Rom' not found. Supply your own legally-dumped copy." }
if (-not (Test-Path $recomp)) { throw "Recompiler not built: $recomp (build ..\smsggrecomp\recompiler first)." }

Write-Host "[1/2] Regenerating native C from $Rom ..."
& $recomp $Rom --game game.toml
if ($LASTEXITCODE -ne 0) { throw "recompiler failed ($LASTEXITCODE)" }

Write-Host "[2/2] Compiling windowed build -> $out ..."
$gccArgs = @(
    "-O1","-DSMSGG_HAVE_GAME_LAYOUT","-DSMS_HAVE_SDL",
    "-I","$runner","-I","$runner\include","-I","$runner\video","-I","$gen","-I","$Sdl\include\SDL2",
    "$runner\main.c","$runner\glue.c","$runner\video\sms_vdp.c","$runner\audio\sn76489.c",
    "$runner\external\superzazu\z80.c","$runner\host_sdl.c",
    "$gen\${prefix}_full.c","$gen\${prefix}_dispatch.c","$gen\${prefix}_layout.c"
)
$gccArgs += @("-L","$Sdl\lib","-lSDL2","-o",$out)
& gcc @gccArgs
if ($LASTEXITCODE -ne 0) { throw "gcc failed ($LASTEXITCODE)" }

Copy-Item (Join-Path $Sdl "bin\SDL2.dll") . -Force -ErrorAction SilentlyContinue
Write-Host "Done: $out  (run: .\$out $Rom --window 3)"
