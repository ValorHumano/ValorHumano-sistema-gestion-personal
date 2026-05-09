@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\GnsPersonal.exe

echo Abriendo GNS Personal PRO desde la ruta local exacta...
echo %EXE%
echo.

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

cd /d "%BASE%"
start "GNS Personal PRO Local" "%EXE%"
exit /b 0
