@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set PS1=%~dp0reparar_cargos_error6_desbordamiento.ps1
set LOG=%BASE%\ejecutar_reparar_cargos_error6_desbordamiento_log.txt

echo ============================================================
echo REPARAR CARGOS - ERROR 6 DESBORDAMIENTO
echo ============================================================
echo.
echo Este proceso HACE BACKUP de Personal.mdb antes de modificar.
echo Corrige valores vacios en Cargos.Laudo y Cargos.id_CobraPor.
echo Esta reparacion apunta al error mostrado en Cargos de los Empleados.
echo.
echo Cierre Sistema de Gestion antes de continuar.
echo.
pause

if not exist "%PS1%" (
  echo ERROR: No se encontro:
  echo %PS1%
  echo.
  echo Descargue tambien reparar_cargos_error6_desbordamiento.ps1
  echo y pongalo en la misma carpeta que este BAT.
  pause
  exit /b 1
)

echo INICIO %DATE% %TIME% > "%LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" >> "%LOG%" 2>&1
set EXITCODE=%ERRORLEVEL%

echo.
echo PowerShell termino con codigo: %EXITCODE%
if not "%EXITCODE%"=="0" (
  echo.
  echo Hubo error. Log:
  type "%LOG%"
  pause
  exit /b %EXITCODE%
)

echo.
echo Reparacion terminada.
echo Revise logs en:
echo %BASE%
dir "%BASE%\reparar_cargos_error6_desbordamiento_*.txt" /b /o-d
echo.
echo Ahora abra Sistema de Gestion y pruebe Datos Basicos > Cargos.
echo.
pause
