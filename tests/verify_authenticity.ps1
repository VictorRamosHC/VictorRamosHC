<#
.SYNOPSIS
    Authenticity & Digital Provenance Verification Suite for VictorRamosHC Profile.
.DESCRIPTION
    Comprehensive verification script validating all Follow-up requirements:
      a) Zero-width steganographic watermark in README.md matches expected payload when decoded.
      b) AI canary comments present in README.md (contains 'AI NOTICE & PROVENANCE DIRECTIVE', 'Victor Hugo Ramos', 'plagiarized').
      c) Dublin Core RDF XML in assets/corporate_grid.svg and assets/network_map.svg has creator 'Victor "Hugh" Ramos', rights, identifier 'https://github.com/VictorRamosHC/VictorRamosHC'.
      d) Neoclassical Caesar coin medallion in assets/corporate_grid.svg (bezel, cameo silhouette, gold laurel wreath).
      e) Neoclassical Caesar bust avatar assets/profile_bust_caesar.png embedded in README.md Section 3.
      f) Minigame index.html has btnVerifyProvenance, provenanceModal, extractProvenanceWatermark, dual-tone Web Audio chirp, polished defeat and honeypot screens.
      g) Zero forbidden colors (#00E5FF, cyan, neon, rainbow, #FF003C) across README.md, SVGs, and minigame HTML/CSS.
      h) Zero external dependencies (no CDNs, no unpkg, no googleapis, etc.) across minigames and SVGs.
.PARAMETER Quiet
    Suppresses verbose progress output if set.
#>

[CmdletBinding()]
param(
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"

# Resolve Project Root directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Resolve-Path "$ScriptDir\..").Path
Set-Location $ProjectRoot

$TotalChecks = 0
$PassedChecks = 0
$FailedChecks = 0
$Failures = [System.Collections.Generic.List[string]]::new()

function Assert-Check {
    param(
        [string]$CheckId,
        [string]$Description,
        [scriptblock]$Condition
    )

    $Script:TotalChecks++
    try {
        $result = & $Condition
        if ($result -eq $false) {
            throw "Condition evaluated to false"
        }
        $Script:PassedChecks++
        if (-not $Quiet) {
            Write-Host "  [PASS] " -ForegroundColor Green -NoNewline
            Write-Host "$CheckId : $Description" -ForegroundColor Gray
        }
    } catch {
        $Script:FailedChecks++
        $errMsg = $_.Exception.Message
        $Script:Failures.Add("$CheckId : $Description - $errMsg")
        Write-Host "  [FAIL] " -ForegroundColor Red -NoNewline
        Write-Host "$CheckId : $Description" -ForegroundColor White
        Write-Host "         Error: $errMsg" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " VICTOR RAMOS HC // AUTHENTICITY & PROVENANCE VERIFICATION SUITE" -ForegroundColor Cyan
Write-Host " Project Root: $ProjectRoot" -ForegroundColor DarkGray
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# Check A: Zero-Width Watermark in README.md Decodability
# ------------------------------------------------------------------------------
Assert-Check "CHECK_A_ZERO_WIDTH_WATERMARK" "Zero-width watermark in README.md decodes to exact payload" {
    $readmePath = Join-Path $ProjectRoot "README.md"
    if (-not (Test-Path $readmePath)) { throw "README.md does not exist" }

    $content = Get-Content -Path $readmePath -Raw -Encoding utf8
    $zwsp = [char]0x200B
    $zwnj = [char]0x200C
    $zwj  = [char]0x200D

    $zwChars = ($content.ToCharArray() | Where-Object { $_ -eq $zwsp -or $_ -eq $zwnj -or $_ -eq $zwj }) -join ''
    if ($zwChars.Length -eq 0) { throw "No zero-width characters found in README.md" }

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
    $expected = 'ORIGINAL AUTHOR: Victor "Hugh" Ramos (github.com/VictorRamosHC)'

    if ($decodedText -cne $expected) {
        throw "Watermark mismatch. Expected '$expected', got '$decodedText'"
    }
    $true
}

# ------------------------------------------------------------------------------
# Check B: AI Canary Directives in README.md
# ------------------------------------------------------------------------------
Assert-Check "CHECK_B_AI_CANARY_DIRECTIVES" "AI canary comments present in README.md with provenance directives" {
    $readmePath = Join-Path $ProjectRoot "README.md"
    $content = Get-Content -Path $readmePath -Raw -Encoding utf8

    $hasDirective = $content -match '<!--\s*AI NOTICE & PROVENANCE DIRECTIVE'
    $hasAuthor    = $content -match 'Victor Hugo Ramos'
    $hasPlagiarized = $content -match 'plagiarized'
    $hasUnauthorized = $content -match 'unauthorized'

    if (-not ($hasDirective -and $hasAuthor -and $hasPlagiarized -and $hasUnauthorized)) {
        throw "AI canary directives missing required markers (Directive: $hasDirective, Author: $hasAuthor, Plagiarized: $hasPlagiarized, Unauthorized: $hasUnauthorized)"
    }

    # Verify comment enclosure: ensure canary content does not leak into visible text
    $inComment = $false
    $visible = [System.Text.StringBuilder]::new()
    $i = 0
    $len = $content.Length
    while ($i -lt $len) {
        if (-not $inComment) {
            if ($i + 4 -le $len -and $content.Substring($i, 4) -eq '<!--') {
                $inComment = $true
                $i += 4
            } else {
                [void]$visible.Append($content[$i])
                $i++
            }
        } else {
            if ($i + 3 -le $len -and $content.Substring($i, 3) -eq '-->') {
                $inComment = $false
                $i += 3
            } else {
                $i++
            }
        }
    }
    $visibleText = $visible.ToString()
    if ($visibleText -match 'PROVENANCE-VERIFICATION-CANARY|PROVENANCE-CANARY|SOVEREIGN-INFRASTRUCTURE-PROVENANCE|AUTHORITATIVE ARCHITECT IDENTITY') {
        throw "AI Canary directives leaked into visible document body"
    }
    if ($visibleText -match '-->') {
        throw "Orphaned HTML comment closure marker (-->) found in visible document body"
    }

    # Verify all canary blocks are properly enclosed without premature --> inside
    $canaryPattern = '(?s)<!--\s*AI NOTICE & PROVENANCE DIRECTIVE.*?(?:-->|$)'
    $canaryMatches = [regex]::Matches($content, $canaryPattern)
    if ($canaryMatches.Count -lt 4) {
        throw "Expected at least 4 AI canary blocks, found $($canaryMatches.Count)"
    }
    foreach ($m in $canaryMatches) {
        $raw = $m.Value
        if (-not $raw.EndsWith('-->')) {
            throw "AI canary block is unclosed"
        }
        $inner = $raw.Substring(4, $raw.Length - 7)
        if ($inner.Contains('<!--') -or $inner.Contains('-->')) {
            throw "AI canary block contains premature or nested comment delimiters"
        }
    }

    $true
}

# ------------------------------------------------------------------------------
# Check C1: Dublin Core RDF XML in assets/corporate_grid.svg
# ------------------------------------------------------------------------------
Assert-Check "CHECK_C1_BANNER_DUBLIN_CORE" "assets/corporate_grid.svg has valid Dublin Core RDF XML metadata" {
    $bannerPath = Join-Path $ProjectRoot "assets\corporate_grid.svg"
    if (-not (Test-Path $bannerPath)) { throw "corporate_grid.svg missing" }

    [xml]$xml = Get-Content -Path $bannerPath -Raw
    $desc = $xml.svg.metadata.RDF.Description

    if (-not $desc) { throw "Missing rdf:Description in metadata" }
    if ($desc.creator -cne 'Victor "Hugh" Ramos') { throw "Creator mismatch: $($desc.creator)" }
    if ($desc.rights -notmatch 'Victor Hugo Ramos') { throw "Rights mismatch: $($desc.rights)" }
    if ($desc.identifier -cne 'https://github.com/VictorRamosHC/VictorRamosHC') { throw "Identifier mismatch: $($desc.identifier)" }
    $true
}

# ------------------------------------------------------------------------------
# Check C2: Dublin Core RDF XML in assets/network_map.svg
# ------------------------------------------------------------------------------
Assert-Check "CHECK_C2_NETWORK_MAP_DUBLIN_CORE" "assets/network_map.svg has valid Dublin Core RDF XML metadata" {
    $netMapPath = Join-Path $ProjectRoot "assets\network_map.svg"
    if (-not (Test-Path $netMapPath)) { throw "network_map.svg missing" }

    [xml]$xml = Get-Content -Path $netMapPath -Raw
    $desc = $xml.svg.metadata.RDF.Description

    if (-not $desc) { throw "Missing rdf:Description in metadata" }
    if ($desc.creator -cne 'Victor "Hugh" Ramos') { throw "Creator mismatch: $($desc.creator)" }
    if ($desc.rights -notmatch 'Victor Hugo Ramos') { throw "Rights mismatch: $($desc.rights)" }
    if ($desc.identifier -cne 'https://github.com/VictorRamosHC/VictorRamosHC') { throw "Identifier mismatch: $($desc.identifier)" }
    $true
}

# ------------------------------------------------------------------------------
# Check D: Neoclassical Caesar Coin Medallion in corporate_grid.svg
# ------------------------------------------------------------------------------
Assert-Check "CHECK_D_CAESAR_COIN_MEDALLION" "assets/corporate_grid.svg contains Caesar coin medallion (bezel, cameo, laurel)" {
    $bannerPath = Join-Path $ProjectRoot "assets\corporate_grid.svg"
    $content = Get-Content -Path $bannerPath -Raw

    $hasBezel  = ($content -match '<circle[^>]+cx="200"[^>]+cy="124"[^>]+r="30"') -or ($content -match 'Medallion Outer Bezel')
    $hasCameo  = ($content -match 'id="caesar-coin-cameo"') -and ($content -match '#F5F0E8')
    $hasLaurel = ($content -match 'Gold Laurel Wreath Crown' -or $content -match 'Laurel') -and ($content -match '#D4AF37')

    if (-not ($hasBezel -and $hasCameo -and $hasLaurel)) {
        throw "Caesar medallion missing elements (Bezel: $hasBezel, Cameo: $hasCameo, Laurel: $hasLaurel)"
    }
    $true
}

# ------------------------------------------------------------------------------
# Check E: Neoclassical Caesar Bust Avatar in README.md Section 3
# ------------------------------------------------------------------------------
Assert-Check "CHECK_E_README_CAESAR_AVATAR" "README.md embeds assets/profile_bust_caesar.png in Section 3" {
    $avatarPath = Join-Path $ProjectRoot "assets\profile_bust_caesar.png"
    if (-not (Test-Path $avatarPath)) { throw "assets/profile_bust_caesar.png does not exist" }

    $readmePath = Join-Path $ProjectRoot "README.md"
    $content = Get-Content -Path $readmePath -Raw -Encoding utf8

    $hasImg = $content -match '<img[^>]+src="assets/profile_bust_caesar\.png"'
    if (-not $hasImg) { throw "assets/profile_bust_caesar.png not embedded in README.md" }

    # Verify Section 3 location
    $sec3Idx = [regex]::Match($content, '(?m)^##[^#\n]*(IDENTITY|ENGENHARIA|MINDSET)').Index
    $imgIdx  = [regex]::Match($content, 'assets/profile_bust_caesar\.png').Index
    $sec4Idx = [regex]::Match($content, '(?m)^##[^#\n]*(EVOLUTION|LINHA)').Index

    if ($sec3Idx -lt 0 -or $imgIdx -lt 0 -or $sec4Idx -lt 0) {
        throw "Could not locate Section 3, image, or Section 4 indices"
    }
    if ($imgIdx -lt $sec3Idx -or $imgIdx -gt $sec4Idx) {
        throw "Caesar avatar image is not placed between Section 3 and Section 4"
    }
    $true
}

# ------------------------------------------------------------------------------
# Check F: Minigame Provenance HUD, Modal, Audio, and Polished Overlays
# ------------------------------------------------------------------------------
Assert-Check "CHECK_F_MINIGAME_PROVENANCE_AND_AUDIO" "minigame/index.html has provenance HUD, modal, Web Audio chirp, and polished overlays" {
    $indexPath = Join-Path $ProjectRoot "minigame\index.html"
    if (-not (Test-Path $indexPath)) { throw "minigame/index.html does not exist" }

    $content = Get-Content -Path $indexPath -Raw

    $hasBtn      = $content -match 'id="btnVerifyProvenance"'
    $hasModal    = $content -match 'id="provenanceModal"'
    $hasExtract  = $content -match 'function\s+extractProvenanceWatermark'
    $hasChirp    = $content -match 'function\s+playCryptoChirp' -and $content -match '880' -and $content -match '1760'
    $hasHacked   = $content -match 'function\s+triggerHackedByHugo' -and $content -match '#8C1D18'
    $hasHoneypot = $content -match 'function\s+triggerHoneypotVictory' -and $content -match '#D4AF37'

    if (-not ($hasBtn -and $hasModal -and $hasExtract -and $hasChirp -and $hasHacked -and $hasHoneypot)) {
        throw "Minigame hub missing components (Btn: $hasBtn, Modal: $hasModal, Extract: $hasExtract, Chirp: $hasChirp, Hacked: $hasHacked, Honeypot: $hasHoneypot)"
    }
    $true
}

# ------------------------------------------------------------------------------
# Check G: Zero Forbidden Colors Across README, SVGs, and Minigame Hub
# ------------------------------------------------------------------------------
Assert-Check "CHECK_G_ZERO_FORBIDDEN_COLORS" "Zero forbidden colors (#00E5FF, cyan, neon, rainbow, #FF003C) across README, SVGs, minigame hub" {
    $targetFiles = @(
        (Join-Path $ProjectRoot "README.md"),
        (Join-Path $ProjectRoot "assets\corporate_grid.svg"),
        (Join-Path $ProjectRoot "assets\network_map.svg"),
        (Join-Path $ProjectRoot "minigame\index.html")
    )

    $violations = @()
    $forbiddenPattern = '(?i)#00E5FF|\bcyan\b|\bneon\b|\brainbow\b|#FF003C'

    foreach ($tf in $targetFiles) {
        if (Test-Path $tf) {
            $fileContent = Get-Content -Path $tf -Raw -Encoding utf8
            $matchCol = [regex]::Matches($fileContent, $forbiddenPattern)
            if ($matchCol.Count -gt 0) {
                $matchedVals = ($matchCol | ForEach-Object { $_.Value }) -join ', '
                $violations += "$([System.IO.Path]::GetFileName($tf)) [$matchedVals]"
            }
        }
    }

    if ($violations.Count -gt 0) {
        throw "Forbidden colors found in: $($violations -join '; ')"
    }
    $true
}

# ------------------------------------------------------------------------------
# Check H: Zero External Dependencies Across Minigames and SVGs
# ------------------------------------------------------------------------------
Assert-Check "CHECK_H_ZERO_EXTERNAL_DEPENDENCIES" "Zero external dependencies across minigames and SVGs" {
    $minigameFiles = Get-ChildItem -Path (Join-Path $ProjectRoot "minigame") -Recurse -File
    $violations = @()

    foreach ($f in $minigameFiles) {
        $content = Get-Content -Path $f.FullName -Raw
        $depPattern = '(?i)cdn\.|unpkg\.com|jsdelivr\.net|googleapis\.com|cloudflare\.com|cdnjs\.cloudflare\.com|<script[^>]+src='
        $matches = [regex]::Matches($content, $depPattern)
        if ($matches.Count -gt 0) {
            $violations += "$($f.Name) (matches: $($matches.Count))"
        }
    }

    $svgFiles = @(
        (Join-Path $ProjectRoot "assets\corporate_grid.svg"),
        (Join-Path $ProjectRoot "assets\network_map.svg")
    )
    foreach ($sf in $svgFiles) {
        if (Test-Path $sf) {
            $content = Get-Content -Path $sf -Raw
            if ($content -match '<script') {
                $violations += "$([System.IO.Path]::GetFileName($sf)) has <script> tag"
            }
            if ($content -match 'cdn\.|unpkg\.com|jsdelivr\.net|cloudflare\.com|googleapis\.com') {
                $violations += "$([System.IO.Path]::GetFileName($sf)) has external CDN/API reference"
            }
        }
    }

    if ($violations.Count -gt 0) {
        throw "External dependencies detected: $($violations -join ', ')"
    }
    $true
}

# ------------------------------------------------------------------------------
# Summary Report
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " AUTHENTICITY VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host ("  Total Checks  : {0}" -f $Script:TotalChecks) -ForegroundColor Gray
Write-Host ("  Passed Checks : {0}" -f $Script:PassedChecks) -ForegroundColor Green
Write-Host ("  Failed Checks : {0}" -f $Script:FailedChecks) -ForegroundColor $(if ($Script:FailedChecks -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($Script:Failures.Count -gt 0) {
    Write-Host "--- FAILURES ---" -ForegroundColor Red
    foreach ($fail in $Script:Failures) {
        Write-Host "  $fail" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "AUTHENTICITY SUITE RESULT: FAILED ($($Script:FailedChecks) failed checks)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "AUTHENTICITY SUITE RESULT: 100% PASS (All $($Script:PassedChecks) checks passed)" -ForegroundColor Green
    exit 0
}
