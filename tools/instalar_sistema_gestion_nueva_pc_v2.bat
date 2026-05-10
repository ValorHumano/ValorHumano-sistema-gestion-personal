@echo off
setlocal EnableExtensions

set SRC=%~dp0
set DEST=C:\GNS Software\GNS Personal PRO
set REGKEY=HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk
set LOG=%TEMP%\instalacion_sistema_gestion_log.txt

echo ============================================================
echo INSTALAR SISTEMA DE GESTION EN NUEVA PC - V2
echo ============================================================
echo.
echo IMPORTANTE: ejecutar como Administrador.
echo Origen:  %SRC%
echo Destino: %DEST%
echo.
pause

echo INSTALACION SISTEMA DE GESTION %DATE% %TIME% > "%LOG%"

if not exist "%SRC%SistemaGestion.exe" (
  echo ERROR: No se encontro SistemaGestion.exe en el paquete.
  echo ERROR: No se encontro SistemaGestion.exe en %SRC% >> "%LOG%"
  pause
  exit /b 1
)

if not exist "%SRC%Usuarios.mdb" (
  echo ERROR: No se encontro Usuarios.mdb en el paquete.
  echo ERROR: No se encontro Usuarios.mdb en %SRC% >> "%LOG%"
  pause
  exit /b 1
)

if not exist "%SRC%Valor Humano\Personal.mdb" (
  echo ERROR: No se encontro Valor Humano\Personal.mdb en el paquete.
  echo ERROR: No se encontro Valor Humano\Personal.mdb >> "%LOG%"
  pause
  exit /b 1
)

if not exist "C:\GNS Software" mkdir "C:\GNS Software"
if not exist "%DEST%" mkdir "%DEST%"

echo Copiando archivos...
robocopy "%SRC%" "%DEST%" /E /XF "instalar_sistema_gestion_nueva_pc_v2.bat" >> "%LOG%" 2>&1

echo Configurando rutas del registro...
reg add "%REGKEY%" /v PathAplicacion /t REG_SZ /d "C:\GNS Software\GNS Personal PRO\\" /f >> "%LOG%" 2>&1
reg add "%REGKEY%" /v BaseGral /t REG_SZ /d "C:\GNS Software\GNS Personal PRO\\" /f >> "%LOG%" 2>&1
reg add "%REGKEY%" /v BaseGralLstEmp /t REG_SZ /d "C:\GNS Software\GNS Personal PRO\\" /f >> "%LOG%" 2>&1

echo Registrando OCX/DLL locales...
for %%F in ("%DEST%\*.ocx" "%DEST%\*.dll") do (
  if exist "%%~fF" (
    C:\Windows\SysWOW64\regsvr32.exe /s "%%~fF" >> "%LOG%" 2>&1
  )
)

echo Creando carpetas operativas si faltan...
if not exist "%DEST%\Valor Humano\Respaldos" mkdir "%DEST%\Valor Humano\Respaldos"
if not exist "%DEST%\Valor Humano\HistorialLaboral" mkdir "%DEST%\Valor Humano\HistorialLaboral"
if not exist "%DEST%\Valor Humano\imgEmpleados" mkdir "%DEST%\Valor Humano\imgEmpleados"
if not exist "%DEST%\Valor Humano\MTSS" mkdir "%DEST%\Valor Humano\MTSS"
if not exist "%DEST%\Valor Humano\Reportes" mkdir "%DEST%\Valor Humano\Reportes"

echo Creando acceso directo...
if exist "%DEST%\abrir_sistema_gestion_titulo_limpio_v5.vbs" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='wscript.exe'; $s.Arguments='""%DEST%\abrir_sistema_gestion_titulo_limpio_v5.vbs""'; $s.WorkingDirectory='%DEST%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%DEST%\SistemaGestion.exe,0'; $s.Save()" >> "%LOG%" 2>&1
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%DEST%\SistemaGestion.exe'; $s.WorkingDirectory='%DEST%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%DEST%\SistemaGestion.exe,0'; $s.Save()" >> "%LOG%" 2>&1
)

echo.
echo Instalacion finalizada.
echo Log: %LOG%
echo.
echo Ahora ejecute verificar_instalacion_sistema_gestion.vbs desde:
echo %DEST%
echo.
echo Luego abra desde el escritorio: Sistema de Gestion
echo.
pause
