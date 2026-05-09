@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set OUTROOT=C:\SistemaGestion_Instalador
set PKG=%OUTROOT%\SistemaGestion_Paquete
set ZIP=%OUTROOT%\SistemaGestion_Paquete.zip

echo ============================================================
echo PREPARAR PAQUETE DE INSTALACION - SISTEMA DE GESTION
echo ============================================================
echo.
echo Este proceso copia la instalacion local funcional a un paquete
echo para instalar en otra PC.
echo.
echo Origen: %BASE%
echo Destino: %PKG%
echo.
pause

if not exist "%BASE%\SistemaGestion.exe" (
  echo ERROR: No existe SistemaGestion.exe en %BASE%
  echo Verifique que ya haya creado y probado la copia rebrandeada.
  pause
  exit /b 1
)

if not exist "%BASE%\Valor Humano\Personal.mdb" (
  echo ERROR: No existe la base de empresa Valor Humano.
  pause
  exit /b 1
)

if exist "%PKG%" rmdir /s /q "%PKG%"
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
mkdir "%PKG%"

echo Copiando archivos principales...
robocopy "%BASE%" "%PKG%" /E /XD "_Demos_Backup" "_Branding_Backup" /XF "*.ldb" "*.log" "diagnostico_*.txt" "analisis_*.txt" "estructura_base_*.txt" "simulacion_*.txt" "verificacion_*.txt" "limpieza_*.txt" >nul

echo Copiando instalador para nueva PC dentro del paquete...
copy "%~dp0instalar_sistema_gestion_nueva_pc.bat" "%PKG%\instalar_sistema_gestion_nueva_pc.bat" >nul 2>&1

echo Creando ZIP...
if exist "%ZIP%" del "%ZIP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%PKG%\*' -DestinationPath '%ZIP%' -Force"

if not exist "%ZIP%" (
  echo ERROR: No se pudo crear el ZIP.
  pause
  exit /b 1
)

echo.
echo Paquete creado correctamente:
echo %ZIP%
echo.
echo Copie ese ZIP a la nueva PC y ejecute instalar_sistema_gestion_nueva_pc.bat como administrador.
echo.
pause
