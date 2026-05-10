@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\SistemaGestion.exe
set OUT=%BASE%\busqueda_textos_marca_en_exe.txt
set ERR=%BASE%\busqueda_textos_marca_error.txt

echo ============================================================
echo BUSQUEDA DEBUG V2 DE TEXTOS EN SistemaGestion.exe
echo ============================================================
echo.
echo Este archivo NO modifica nada.
echo.
echo EXE: %EXE%
echo OUT: %OUT%
echo ERR: %ERR%
echo.
pause

if exist "%ERR%" del "%ERR%"
if exist "%OUT%" del "%OUT%"

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%" > "%ERR%"
  echo ERROR: No existe "%EXE%"
  echo.
  echo Abra el archivo: %ERR%
  pause
  exit /b 1
)

echo Ejecutando PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$exe='C:\GNS Software\GNS Personal PRO\SistemaGestion.exe'; $out='C:\GNS Software\GNS Personal PRO\busqueda_textos_marca_en_exe.txt'; $bytes=[IO.File]::ReadAllBytes($exe); $ansi=[Text.Encoding]::Default.GetString($bytes); $uni=[Text.Encoding]::Unicode.GetString($bytes); $terms=@('GNS','GNS Personal','GnsPersonal','Personal','Evaluacion','Evaluación','Version','Versión','Mejora','4.1','4.1 Mejora 90','SistemaGestion','Sistema de Gestion'); $lines=@(); $lines+='BUSQUEDA DEBUG V2 DE TEXTOS EN SistemaGestion.exe'; $lines+='Fecha: '+(Get-Date); $lines+='Exe: '+$exe; $lines+='Bytes: '+$bytes.Length; $lines+='------------------------------------------------------------------------------------------'; foreach($t in $terms){ $ia=$ansi.IndexOf($t,[StringComparison]::OrdinalIgnoreCase); $iu=$uni.IndexOf($t,[StringComparison]::OrdinalIgnoreCase); $lines+=''; $lines+='TERMINO: '+$t; $lines+='ANSI encontrado: '+($ia -ge 0)+' posicion='+$ia; if($ia -ge 0){$s=[Math]::Max(0,$ia-80); $l=[Math]::Min(260,$ansi.Length-$s); $lines+='ANSI contexto: '+(($ansi.Substring($s,$l)) -replace '[\x00-\x1F]',' ')}; $lines+='UNICODE encontrado: '+($iu -ge 0)+' posicion='+$iu; if($iu -ge 0){$s=[Math]::Max(0,$iu-80); $l=[Math]::Min(260,$uni.Length-$s); $lines+='UNICODE contexto: '+(($uni.Substring($s,$l)) -replace '[\x00-\x1F]',' ')} }; $lines+=''; $lines+='------------------------------------------------------------------------------------------'; $lines+='FIN'; $lines | Set-Content -Path $out -Encoding UTF8; Write-Host 'OK reporte generado:' $out" 2> "%ERR%"

set PS_EXIT=%ERRORLEVEL%
echo.
echo PowerShell termino con codigo: %PS_EXIT%
echo.

if exist "%ERR%" (
  for %%A in ("%ERR%") do if %%~zA GTR 0 (
    echo Hubo error. Abra:
    echo %ERR%
    echo.
    type "%ERR%"
    echo.
    pause
    exit /b 1
  )
)

if exist "%OUT%" (
  echo Reporte generado:
  echo %OUT%
  echo.
  echo Abra ese archivo y peguelo en ChatGPT.
) else (
  echo No se genero el reporte.
)

pause
