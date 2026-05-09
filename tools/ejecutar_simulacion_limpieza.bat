@echo off
setlocal

set SCRIPT_DIR=%~dp0
set VBS=%SCRIPT_DIR%simular_limpieza_base_valor_humano.vbs
set CSCRIPT32=C:\Windows\SysWOW64\cscript.exe

echo Ejecutando simulacion de limpieza de base Valor Humano...
echo NO se modificara la base.
echo.

if not exist "%VBS%" (
  echo ERROR: No se encontro "%VBS%"
  echo Guarde este BAT en la misma carpeta que simular_limpieza_base_valor_humano.vbs
  pause
  exit /b 1
)

"%CSCRIPT32%" //nologo "%VBS%"

echo.
echo Abra y pegue en ChatGPT el archivo:
echo C:\GNS Software\GNS Personal PRO\Valor Humano\simulacion_limpieza_valor_humano.txt
echo.
pause
