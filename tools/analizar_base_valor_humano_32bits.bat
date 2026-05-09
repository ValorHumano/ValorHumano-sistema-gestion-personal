@echo off
setlocal

set SCRIPT_DIR=%~dp0
set VBS=%SCRIPT_DIR%analizar_base_valor_humano.vbs
set CSCRIPT32=C:\Windows\SysWOW64\cscript.exe

echo Analizando base Valor Humano usando motor 32 bits...
echo.

if not exist "%VBS%" (
  echo ERROR: No se encontro el archivo:
  echo "%VBS%"
  echo.
  echo Guarde este BAT en la misma carpeta que analizar_base_valor_humano.vbs
  pause
  exit /b 1
)

if not exist "%CSCRIPT32%" (
  echo ERROR: No se encontro cscript 32 bits:
  echo "%CSCRIPT32%"
  pause
  exit /b 1
)

"%CSCRIPT32%" //nologo "%VBS%"

echo.
echo Si el analisis fue correcto, abra:
echo C:\GNS Software\GNS Personal PRO\Valor Humano\estructura_base_valor_humano.txt
echo.
pause
