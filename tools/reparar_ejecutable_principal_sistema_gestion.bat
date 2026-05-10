@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set TARGET=%BASE%\SistemaGestion.exe
set LOG=%BASE%\reparar_ejecutable_principal_sistema_gestion_log.txt
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

echo ============================================================
echo REPARAR EJECUTABLE PRINCIPAL - SISTEMA DE GESTION
echo ============================================================
echo.
echo Este proceso verifica si existe SistemaGestion.exe.
echo Si falta, intenta restaurarlo desde una copia local conocida.
echo No toca bases MDB, usuarios, licencias ni datos.
echo.
pause

echo REPARAR EJECUTABLE PRINCIPAL %DATE% %TIME% > "%LOG%"
echo BASE=%BASE% >> "%LOG%"
echo TARGET=%TARGET% >> "%LOG%"
echo. >> "%LOG%"

if not exist "%BASE%" (
  echo ERROR: No existe carpeta base: %BASE%
  echo ERROR: No existe carpeta base >> "%LOG%"
  pause
  exit /b 1
)

if exist "%TARGET%" (
  echo OK: Ya existe SistemaGestion.exe
  echo OK: Ya existe SistemaGestion.exe >> "%LOG%"
) else (
  echo FALTA: SistemaGestion.exe
  echo FALTA: SistemaGestion.exe >> "%LOG%"
  set SRC=

  if exist "%BASE%\SistemaGestion_original.exe" set SRC=%BASE%\SistemaGestion_original.exe
  if not defined SRC if exist "%BASE%\GnsPersonal.exe" set SRC=%BASE%\GnsPersonal.exe
  if not defined SRC if exist "%BASE%\GNS Personal PRO.exe" set SRC=%BASE%\GNS Personal PRO.exe
  if not defined SRC if exist "%BASE%\GnsPersonal" set SRC=%BASE%\GnsPersonal

  if not defined SRC (
    echo ERROR: No encontre copia local para restaurar el ejecutable.
    echo ERROR: No encontre copia local para restaurar ejecutable >> "%LOG%"
    echo.
    echo Busque manualmente algun EXE dentro de:
    echo %BASE%
    echo.
    dir "%BASE%\*.exe" /b >> "%LOG%" 2>&1
    pause
    exit /b 1
  )

  echo Restaurando desde: %SRC%
  echo Restaurando desde: %SRC% >> "%LOG%"
  copy "%SRC%" "%TARGET%" /Y >> "%LOG%" 2>&1

  if exist "%TARGET%" (
    echo OK: SistemaGestion.exe restaurado.
    echo OK: SistemaGestion.exe restaurado >> "%LOG%"
  ) else (
    echo ERROR: No se pudo restaurar SistemaGestion.exe.
    echo ERROR: No se pudo restaurar SistemaGestion.exe >> "%LOG%"
    pause
    exit /b 1
  )
)

echo.
echo Recreando acceso directo del escritorio...
echo Recreando acceso directo >> "%LOG%"
if exist "%SHORTCUT%" del "%SHORTCUT%" >> "%LOG%" 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%TARGET%'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%TARGET%,0'; $s.Save()" >> "%LOG%" 2>&1

echo.
echo Verificacion final:
if exist "%TARGET%" (
  echo OK: %TARGET%
  echo OK final: %TARGET% >> "%LOG%"
) else (
  echo FALTA: %TARGET%
  echo FALTA final: %TARGET% >> "%LOG%"
)

echo.
echo Log:
echo %LOG%
echo.
echo Ahora vuelva a ejecutar el diagnostico avanzado integral.
echo.
pause
