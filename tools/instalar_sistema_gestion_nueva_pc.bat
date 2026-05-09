@echo off
setlocal

set SRC=%~dp0
set DEST=C:\GNS Software\GNS Personal PRO
set REGKEY=HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

echo ============================================================
echo INSTALAR SISTEMA DE GESTION EN NUEVA PC
echo ============================================================
echo.
echo IMPORTANTE: ejecutar este archivo como Administrador.
echo.
echo Origen: %SRC%
echo Destino: %DEST%
echo.
pause

if not exist "%SRC%SistemaGestion.exe" (
  echo ERROR: Este instalador debe ejecutarse desde la carpeta extraida del paquete.
  echo No se encontro SistemaGestion.exe en: %SRC%
  pause
  exit /b 1
)

if not exist "C:\GNS Software" mkdir "C:\GNS Software"
if exist "%DEST%" (
  echo Ya existe una instalacion en:
  echo %DEST%
  echo.
  echo Se copiara encima conservando la carpeta existente.
  pause
) else (
  mkdir "%DEST%"
)

echo Copiando archivos...
robocopy "%SRC%" "%DEST%" /E /XF "instalar_sistema_gestion_nueva_pc.bat" >nul

echo Configurando registro...
reg add "%REGKEY%" /v PathAplicacion /t REG_SZ /d "C:\GNS Software\GNS Personal PRO\\" /f
reg add "%REGKEY%" /v BaseGral /t REG_SZ /d "C:\GNS Software\GNS Personal PRO\\" /f
reg add "%REGKEY%" /v BaseGralLstEmp /t REG_SZ /d "C:\GNS Software\GNS Personal PRO\\" /f

echo Registrando componentes VB6/OCX si existen...
for %%F in ("%DEST%\*.ocx" "%DEST%\*.dll") do (
  if exist "%%~fF" (
    C:\Windows\SysWOW64\regsvr32.exe /s "%%~fF" >nul 2>&1
  )
)

echo Creando acceso directo...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%DEST%\SistemaGestion.exe'; $s.WorkingDirectory='%DEST%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%DEST%\SistemaGestion.exe,0'; $s.Save()"

echo.
echo Instalacion finalizada.
echo Abra desde el escritorio: Sistema de Gestion
echo.
echo Si aparece un error de componente OCX/DLL, reinicie la PC y pruebe de nuevo.
echo.
pause
