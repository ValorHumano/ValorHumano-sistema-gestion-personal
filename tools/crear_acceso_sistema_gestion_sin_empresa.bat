@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\GnsPersonal.exe
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

echo Creando acceso directo en el Escritorio...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%EXE%'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%EXE%,0'; $s.Save()"

echo.
echo Acceso creado:
echo %SHORTCUT%
echo.
echo Use este acceso como entrada principal del sistema.
echo Puede borrar del escritorio los accesos viejos que digan GNS o Valor Humano.
pause
