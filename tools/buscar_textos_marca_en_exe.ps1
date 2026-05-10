$ErrorActionPreference = 'Stop'

$Base = 'C:\GNS Software\GNS Personal PRO'
$Exe = Join-Path $Base 'SistemaGestion.exe'
$Out = Join-Path $Base 'busqueda_textos_marca_en_exe.txt'

$terms = @(
  'GNS',
  'GNS Personal',
  'GnsPersonal',
  'Personal',
  'Evaluacion',
  'Evaluación',
  'Version',
  'Versión',
  'Mejora',
  '4.1',
  '4.1 Mejora 90'
)

function Find-Bytes([byte[]]$Data, [byte[]]$Needle) {
  $positions = New-Object System.Collections.Generic.List[int]
  if ($Needle.Length -eq 0 -or $Data.Length -lt $Needle.Length) { return $positions }
  $max = $Data.Length - $Needle.Length
  for ($i = 0; $i -le $max; $i++) {
    $ok = $true
    for ($j = 0; $j -lt $Needle.Length; $j++) {
      if ($Data[$i + $j] -ne $Needle[$j]) { $ok = $false; break }
    }
    if ($ok) { $positions.Add($i) }
  }
  return $positions
}

function Safe-Context([byte[]]$Data, [int]$Pos, [int]$Len) {
  $start = [Math]::Max(0, $Pos - 80)
  $end = [Math]::Min($Data.Length - 1, $Pos + $Len + 160)
  $sliceLen = $end - $start + 1
  $slice = New-Object byte[] $sliceLen
  [Array]::Copy($Data, $start, $slice, 0, $sliceLen)
  $txt = [System.Text.Encoding]::Default.GetString($slice)
  $txt = $txt -replace "`0", '.'
  $txt = $txt -replace "[\x00-\x08\x0B\x0C\x0E-\x1F]", ' '
  return $txt
}

if (!(Test-Path $Exe)) { throw "No existe $Exe" }

[byte[]]$data = [System.IO.File]::ReadAllBytes($Exe)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('BUSQUEDA DE TEXTOS DE MARCA EN SistemaGestion.exe')
$lines.Add('Fecha: ' + (Get-Date))
$lines.Add('Exe: ' + $Exe)
$lines.Add(('Bytes: ' + $data.Length))
$lines.Add((''.PadLeft(90, '-')))

foreach ($term in $terms) {
  $ansi = [System.Text.Encoding]::Default.GetBytes($term)
  $unicode = [System.Text.Encoding]::Unicode.GetBytes($term)
  $ansiPositions = Find-Bytes $data $ansi
  $unicodePositions = Find-Bytes $data $unicode

  $lines.Add('')
  $lines.Add("TERMINO: $term")
  $lines.Add("ANSI encontrados: $($ansiPositions.Count)")
  foreach ($p in $ansiPositions | Select-Object -First 20) {
    $lines.Add(('  ANSI offset={0:X8} contexto={1}' -f $p, (Safe-Context $data $p $ansi.Length)))
  }
  $lines.Add("UNICODE encontrados: $($unicodePositions.Count)")
  foreach ($p in $unicodePositions | Select-Object -First 20) {
    $ctxBytes = New-Object byte[] ([Math]::Min(400, $data.Length - $p))
    [Array]::Copy($data, $p, $ctxBytes, 0, $ctxBytes.Length)
    $ctx = [System.Text.Encoding]::Unicode.GetString($ctxBytes)
    $ctx = $ctx -replace "`0", '.'
    $ctx = $ctx -replace "[\x00-\x08\x0B\x0C\x0E-\x1F]", ' '
    $lines.Add(('  UNICODE offset={0:X8} contexto={1}' -f $p, $ctx))
  }
}

$lines.Add('')
$lines.Add((''.PadLeft(90, '-')))
$lines.Add('FIN')
$lines | Set-Content -Path $Out -Encoding UTF8
Write-Host "Reporte generado en: $Out"
