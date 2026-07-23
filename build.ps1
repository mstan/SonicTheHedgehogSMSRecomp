# build.ps1 — regenerate + build SonicTheHedgehogSMSRecomp (windowed) from your ROM.
#
# Requires:
#   - the smsggrecomp submodule initialized in .\smsggrecomp
#     (built recompiler at .\smsggrecomp\recompiler\build\SmsRecomp.exe)
#   - MinGW-w64 gcc + SDL2 dev libs (MSYS2 'mingw64' by default)
#   - your own legally-dumped ROM next to this script
#
# Usage:  powershell -File build.ps1 [-Rom sonicthehedgehog.sms] [-Sdl C:\msys64\mingw64] [-SkipRegenerate]
param(
    [string]$Rom = "sonicthehedgehog.sms",
    [string]$Sdl = "C:\msys64\mingw64",
    [switch]$SkipRegenerate
)
$ErrorActionPreference = "Stop"

$prefix = "sonic1sms"
$out    = "SonicTheHedgehogSMSRecomp.exe"
$engine = (Resolve-Path ".\smsggrecomp").Path
$recomp = Join-Path $engine "recompiler\build\SmsRecomp.exe"
$runner = Join-Path $engine "runner"
$gen    = Join-Path (Get-Location) "generated"

if (-not (Test-Path $Rom))    { throw "ROM '$Rom' not found. Supply your own legally-dumped copy." }
if (-not $SkipRegenerate) {
    if (-not (Test-Path $recomp)) { throw "Recompiler not built: $recomp (initialize and build the smsggrecomp submodule first)." }
    Write-Host "[1/2] Regenerating native C from $Rom ..."
    & $recomp $Rom --game game.toml
    if ($LASTEXITCODE -ne 0) { throw "recompiler failed ($LASTEXITCODE)" }
} else {
    foreach ($name in @("${prefix}_full.c", "${prefix}_dispatch.c", "${prefix}_layout.c")) {
        if (-not (Test-Path (Join-Path $gen $name))) {
            throw "Generated input missing: generated\$name (cannot rebuild without regeneration)."
        }
    }
    Write-Host "[1/2] Reusing existing generated C (-SkipRegenerate)."
}

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
