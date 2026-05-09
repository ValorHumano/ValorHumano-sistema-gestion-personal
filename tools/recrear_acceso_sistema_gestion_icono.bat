@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\SistemaGestion.exe
set ICO=%BASE%\icono_sistema_gestion.ico
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

echo Recreando acceso directo Sistema de Gestion...
echo.

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

if exist "%SHORTCUT%" del "%SHORTCUT%"

if exist "%ICO%" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%EXE%'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%ICO%'; $s.Save()"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%EXE%'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%EXE%,0'; $s.Save()"
)

echo.
echo Acceso recreado:
echo %SHORTCUT%
echo.
echo Si Windows sigue mostrando el icono anterior, cierre sesion y vuelva a entrar,
echo o reinicie el Explorador de Windows.
echo.
pause
