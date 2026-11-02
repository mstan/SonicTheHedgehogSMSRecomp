param(
    [string]$Rom='',
    [string]$Sdl='C:\msys64\mingw64',
    [string]$Build='build',
    [Alias('EngineRoot')][string]$Framework='',
    [switch]$SkipRegenerate,
    [ValidateSet('O1','O2','O3')][string]$Optimization='O2',
    [switch]$PortableDisplay,
    [switch]$ReferenceVDP,
    [switch]$ReferenceExecution,
    [ValidateRange(1,8)][int]$Jobs=2
)
$ErrorActionPreference='Stop'
if(!$Framework) { $Framework=Join-Path $PSScriptRoot 'smsggrecomp' }
& (Join-Path $Framework 'tools/build_game.ps1') -ProjectRoot $PSScriptRoot -Rom $Rom -Sdl $Sdl -Build $Build -SkipRegenerate:$SkipRegenerate -Optimization $Optimization -PortableDisplay:$PortableDisplay -ReferenceVDP:$ReferenceVDP -ReferenceExecution:$ReferenceExecution -Jobs $Jobs
