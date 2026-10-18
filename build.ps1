param(
    [string]$Rom='',
    [string]$Sdl='C:\msys64\mingw64',
    [string]$Build='build',
    [string]$Framework='',
    [switch]$SkipRegenerate
)
$ErrorActionPreference='Stop'
if(!$Framework) { $Framework=Join-Path $PSScriptRoot 'smsggrecomp' }
& (Join-Path $Framework 'tools/build_game.ps1') -ProjectRoot $PSScriptRoot -Rom $Rom -Sdl $Sdl -Build $Build -SkipRegenerate:$SkipRegenerate
