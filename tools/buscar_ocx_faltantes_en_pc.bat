@echo off
setlocal EnableDelayedExpansion

set OUT=C:\GNS Software\GNS Personal PRO\busqueda_ocx_faltantes_en_pc.txt

echo BUSQUEDA DE OCX FALTANTES - SISTEMA DE GESTION > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

set FILES=msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx

echo === UBICACIONES COMUNES === >> "%OUT%"
for %%F in (%FILES%) do (
  echo. >> "%OUT%"
  echo Archivo: %%F >> "%OUT%"
  if exist "C:\GNS Software\GNS Personal PRO\%%F" echo LOCAL: C:\GNS Software\GNS Personal PRO\%%F >> "%OUT%"
  if exist "C:\Windows\SysWOW64\%%F" echo SYSWOW64: C:\Windows\SysWOW64\%%F >> "%OUT%"
  if exist "C:\Windows\System32\%%F" echo SYSTEM32: C:\Windows\System32\%%F >> "%OUT%"
  if exist "C:\Windows\System\%%F" echo SYSTEM: C:\Windows\System\%%F >> "%OUT%"
)

echo. >> "%OUT%"
echo === BUSQUEDA EN C:\GNS Software === >> "%OUT%"
for %%F in (%FILES%) do (
  echo. >> "%OUT%"
  echo Archivo: %%F >> "%OUT%"
  dir "C:\GNS Software\%%F" /s /b 2>nul >> "%OUT%"
)

echo. >> "%OUT%"
echo === BUSQUEDA EN DESCARGAS Y ESCRITORIO DEL USUARIO === >> "%OUT%"
for %%F in (%FILES%) do (
  echo. >> "%OUT%"
  echo Archivo: %%F >> "%OUT%"
  dir "%USERPROFILE%\Downloads\%%F" /s /b 2>nul >> "%OUT%"
  dir "%USERPROFILE%\Desktop\%%F" /s /b 2>nul >> "%OUT%"
)

echo. >> "%OUT%"
echo === BUSQUEDA EN C:\ - PUEDE TARDAR === >> "%OUT%"
for %%F in (%FILES%) do (
  echo. >> "%OUT%"
  echo Archivo: %%F >> "%OUT%"
  dir "C:\%%F" /s /b 2>nul >> "%OUT%"
)

echo. >> "%OUT%"
echo FIN >> "%OUT%"

echo Reporte generado:
echo %OUT%
echo.
echo Pegue ese archivo en ChatGPT.
pause
