@echo off
setlocal EnableExtensions EnableDelayedExpansion

set OUT=C:\GNS Software\GNS Personal PRO\busqueda_ocx_faltantes_rapido.txt
set FILES=msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx

echo ============================================================
echo BUSQUEDA RAPIDA DE OCX FALTANTES
echo ============================================================
echo.
echo Este proceso NO modifica nada. Solo busca archivos.
echo No recorre todo C:\ completo para no quedarse colgado.
echo.
pause

if not exist "C:\GNS Software\GNS Personal PRO" mkdir "C:\GNS Software\GNS Personal PRO"

echo BUSQUEDA RAPIDA DE OCX FALTANTES - SISTEMA DE GESTION > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === ARCHIVOS BUSCADOS === >> "%OUT%"
for %%F in (%FILES%) do echo %%F >> "%OUT%"
echo. >> "%OUT%"

echo === UBICACIONES DIRECTAS === >> "%OUT%"
for %%F in (%FILES%) do (
  echo. >> "%OUT%"
  echo Archivo: %%F >> "%OUT%"
  if exist "C:\GNS Software\GNS Personal PRO\%%F" echo C:\GNS Software\GNS Personal PRO\%%F >> "%OUT%"
  if exist "C:\Windows\SysWOW64\%%F" echo C:\Windows\SysWOW64\%%F >> "%OUT%"
  if exist "C:\Windows\System32\%%F" echo C:\Windows\System32\%%F >> "%OUT%"
  if exist "C:\Windows\System\%%F" echo C:\Windows\System\%%F >> "%OUT%"
)

echo. >> "%OUT%"
echo === BUSQUEDA EN CARPETAS PROBABLES === >> "%OUT%"
for %%R in ("C:\GNS Software" "%USERPROFILE%\Downloads" "%USERPROFILE%\Desktop" "%USERPROFILE%\Documents" "C:\Program Files" "C:\Program Files (x86)" "C:\Windows\SysWOW64" "C:\Windows\System32") do (
  if exist %%~R (
    echo. >> "%OUT%"
    echo --- %%~R --- >> "%OUT%"
    for %%F in (%FILES%) do (
      dir "%%~R\%%F" /s /b 2>nul >> "%OUT%"
    )
  )
)

echo. >> "%OUT%"
echo === BUSQUEDA DENTRO DE ZIP EN DESCARGAS/ESCRITORIO/DOCUMENTOS/GNS === >> "%OUT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$targets=@('msadodc.ocx','comdlg32.ocx','mscomct2.ocx','msflxgrd.ocx'); $roots=@('C:\GNS Software',$env:USERPROFILE+'\Downloads',$env:USERPROFILE+'\Desktop',$env:USERPROFILE+'\Documents'); Add-Type -AssemblyName System.IO.Compression.FileSystem; foreach($r in $roots){ if(Test-Path $r){ Get-ChildItem -Path $r -Recurse -Filter *.zip -ErrorAction SilentlyContinue | ForEach-Object { $zip=$_.FullName; try { $z=[IO.Compression.ZipFile]::OpenRead($zip); foreach($e in $z.Entries){ foreach($t in $targets){ if($e.FullName.ToLower().EndsWith($t.ToLower())){ 'ZIP: '+$zip+' -> '+$e.FullName | Add-Content -Path '%OUT%' } } }; $z.Dispose() } catch {} } } }"

echo. >> "%OUT%"
echo === RESUMEN === >> "%OUT%"
for %%F in (%FILES%) do (
  find /i "%%F" "%OUT%" >nul
  if errorlevel 1 (
    echo NO ENCONTRADO: %%F >> "%OUT%"
  ) else (
    echo REVISAR RESULTADOS PARA: %%F >> "%OUT%"
  )
)

echo. >> "%OUT%"
echo FIN >> "%OUT%"

echo.
echo Reporte generado:
echo %OUT%
echo.
echo Abra ese archivo y peguelo en ChatGPT.
pause
