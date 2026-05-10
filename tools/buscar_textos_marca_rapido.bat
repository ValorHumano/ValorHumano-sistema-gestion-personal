@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\SistemaGestion.exe
set OUT=%BASE%\busqueda_textos_marca_en_exe.txt

echo ============================================================
echo BUSQUEDA RAPIDA DE TEXTOS EN SistemaGestion.exe
echo ============================================================
echo.

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$exe='%EXE%'; $out='%OUT%';" ^
"$bytes=[IO.File]::ReadAllBytes($exe);" ^
"$ansi=[Text.Encoding]::Default.GetString($bytes);" ^
"$uni=[Text.Encoding]::Unicode.GetString($bytes);" ^
"$terms=@('GNS','GNS Personal','GnsPersonal','Personal','Evaluacion','Evaluación','Version','Versión','Mejora','4.1','4.1 Mejora 90','SistemaGestion','Sistema de Gestion');" ^
"$lines=New-Object System.Collections.Generic.List[string];" ^
"$lines.Add('BUSQUEDA RAPIDA DE TEXTOS EN SistemaGestion.exe'); $lines.Add('Fecha: '+(Get-Date)); $lines.Add('Exe: '+$exe); $lines.Add('Bytes: '+$bytes.Length); $lines.Add('-'*90);" ^
"foreach($t in $terms){$ia=$ansi.IndexOf($t,[StringComparison]::OrdinalIgnoreCase); $iu=$uni.IndexOf($t,[StringComparison]::OrdinalIgnoreCase); $lines.Add(''); $lines.Add('TERMINO: '+$t); $lines.Add('ANSI encontrado: '+($ia -ge 0)+' posicion='+$ia); if($ia -ge 0){$s=[Math]::Max(0,$ia-80); $l=[Math]::Min(260,$ansi.Length-$s); $lines.Add('ANSI contexto: '+($ansi.Substring($s,$l) -replace '[\x00-\x1F]',' '));}; $lines.Add('UNICODE encontrado: '+($iu -ge 0)+' posicion='+$iu); if($iu -ge 0){$s=[Math]::Max(0,$iu-80); $l=[Math]::Min(260,$uni.Length-$s); $lines.Add('UNICODE contexto: '+($uni.Substring($s,$l) -replace '[\x00-\x1F]',' '));};}" ^
"$lines.Add(''); $lines.Add('-'*90); $lines.Add('FIN'); $lines | Set-Content -Path $out -Encoding UTF8; Write-Host 'Reporte generado en:' $out;"

echo.
echo Si termino bien, abra y pegue este archivo:
echo %OUT%
echo.
pause
