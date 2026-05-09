@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\GnsPersonal.exe
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion - Valor Humano.lnk

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

echo Creando acceso directo en el Escritorio...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%EXE%'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion - Valor Humano'; $s.IconLocation='%EXE%,0'; $s.Save()"

echo.
echo Acceso creado:
echo %SHORTCUT%
echo.
echo Recomendacion: use este acceso y quite accesos viejos del escritorio/barra.
pause
