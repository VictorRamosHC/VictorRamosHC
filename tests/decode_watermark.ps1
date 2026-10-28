<#
.SYNOPSIS
    Zero-Width Steganographic Provenance Watermark Decoder.
.DESCRIPTION
    Extracts and validates invisible Unicode zero-width payload embedded in README.md.
    Encoding:
      - \u200B (Zero-Width Space)       -> 0
      - \u200C (Zero-Width Non-Joiner)  -> 1
      - \u200D (Zero-Width Joiner)      -> Byte delimiter (8 bits per byte)
.PARAMETER Path
    Path to the Markdown file (default: "README.md").
#>

[CmdletBinding()]
param(
    [string]$Path = "README.md"
)

$ErrorActionPreference = "Stop"

# Resolve path if not found in current directory
$targetPath = $Path
if (-not (Test-Path $targetPath)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $parentPath = Join-Path (Split-Path -Parent $scriptDir) $Path
    if (Test-Path $parentPath) {
        $targetPath = $parentPath
    } else {
        [Console]::Error.WriteLine("Error: Target file not found: $Path")
        exit 1
    }
}

try {
    $content = Get-Content -Path $targetPath -Raw -Encoding utf8
} catch {
    [Console]::Error.WriteLine("Error reading file $targetPath : $_")
    exit 1
}

$zwsp = [char]0x200B  # bit 0
$zwnj = [char]0x200C  # bit 1
$zwj  = [char]0x200D  # byte separator

# Extract zero-width characters in \u200B, \u200C, \u200D
$zwChars = ($content.ToCharArray() | Where-Object { $_ -eq $zwsp -or $_ -eq $zwnj -or $_ -eq $zwj }) -join ''

$chunks = $zwChars.Split($zwj)
$decodedChars = [System.Collections.Generic.List[char]]::new()

foreach ($chunk in $chunks) {
    if ($chunk.Length -eq 8) {
        $byteVal = 0
        for ($i = 0; $i -lt 8; $i++) {
            $bit = if ($chunk[$i] -eq $zwnj) { 1 } else { 0 }
            $byteVal = ($byteVal -shl 1) -bor $bit
        }
        $decodedChars.Add([char]$byteVal)
    }
}

$decodedText = ($decodedChars -join '')
Write-Output $decodedText

$expected = 'ORIGINAL AUTHOR: Victor "Hugh" Ramos (github.com/VictorRamosHC)'

if ($decodedText -ceq $expected) {
    exit 0
} else {
    [Console]::Error.WriteLine("Watermark mismatch!`nExpected: $expected`nDecoded:  $decodedText")
    exit 1
}
