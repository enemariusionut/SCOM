param(
    [Parameter(Mandatory=$true)]
    [string]$File1Path,
    
    [Parameter(Mandatory=$true)]
    [string]$File2Path,

    [Parameter(Mandatory=$false)]
    [switch]$DifferencesOnly
)

function Get-XmlDiff($xml1, $xml2, $showOnlyDifferences) {
    $writer1 = New-Object System.IO.StringWriter
    $writer2 = New-Object System.IO.StringWriter

    $xml1.Save($writer1)
    $xml2.Save($writer2)

    $lines1 = $writer1.ToString() -split "`n"
    $lines2 = $writer2.ToString() -split "`n"

    $diff = Compare-Object $lines1 $lines2 -IncludeEqual

    $result = @()
    $lineNumber1 = 0
    $lineNumber2 = 0

    foreach ($line in $diff) {
        switch ($line.SideIndicator) {
            "==" {
                if (-not $showOnlyDifferences) {
                    $result += @{Text = "  $($line.InputObject)"; Color = "White"; Line1 = $lineNumber1 + 1; Line2 = $lineNumber2 + 1}
                }
                $lineNumber1++
                $lineNumber2++
            }
            "<=" {
                $result += @{Text = "- $($line.InputObject)"; Color = "Red"; Line1 = $lineNumber1 + 1; Line2 = $null}
                $lineNumber1++
            }
            "=>" {
                $result += @{Text = "+ $($line.InputObject)"; Color = "Green"; Line1 = $null; Line2 = $lineNumber2 + 1}
                $lineNumber2++
            }
        }
    }

    return $result
}

# Load XML files
try {
    $xml1 = [xml](Get-Content $File1Path -Encoding UTF8)
    $xml2 = [xml](Get-Content $File2Path -Encoding UTF8)
} catch {
    Write-Error "Error loading XML files: $_"
    exit 1
}

# Compare XML files
$differences = Get-XmlDiff $xml1 $xml2 $DifferencesOnly

#return $differences.Text

# Output results
Write-Host "Diff between $File1Path and $File2Path`:"
Write-Host "----------------------------------------"
foreach ($line in $differences) {
    $lineInfo = ""
    if ($line.Line1 -and $line.Line2) {
        $lineInfo = "[$($line.Line1),$($line.Line2)]"
    } elseif ($line.Line1) {
        $lineInfo = "[$($line.Line1),-]"
    } elseif ($line.Line2) {
        $lineInfo = "[-,$($line.Line2)]"
    }
    Write-Host ("{0,-12}" -f $lineInfo) -NoNewline
    Write-Host $line.Text -ForegroundColor $line.Color
}
