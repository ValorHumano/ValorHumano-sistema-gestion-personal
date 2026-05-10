@echo off
setlocal EnableExtensions EnableDelayedExpansion

set BASE=C:\GNS Software\GNS Personal PRO
set TARGET=%BASE%\SistemaGestion.exe
set LOG=%BASE%\reparar_ejecutable_principal_v2_busqueda_amplia_log.txt
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

echo ============================================================
echo REPARAR EJECUTABLE PRINCIPAL V2 - BUSQUEDA AMPLIA
echo ============================================================
echo.
echo Este proceso busca el ejecutable real en la carpeta actual,
echo en el paquete generado y en ubicaciones probables.
echo No toca bases MDB, usuarios, licencias ni datos.
echo.
pause

if not exist "%BASE%" mkdir "%BASE%"

echo REPARAR EJECUTABLE PRINCIPAL V2 %DATE% %TIME% > "%LOG%"
echo BASE=%BASE% >> "%LOG%"
echo TARGET=%TARGET% >> "%LOG%"
echo. >> "%LOG%"

echo === LISTADO EXE EN BASE === >> "%LOG%"
dir "%BASE%\*.exe" /a:-d /b >> "%LOG%" 2>&1
echo. >> "%LOG%"
echo === LISTADO ARCHIVOS QUE EMPIEZAN CON SISTEMA/GNS === >> "%LOG%"
dir "%BASE%\Sistema*" /a:-d /b >> "%LOG%" 2>&1
dir "%BASE%\Gns*" /a:-d /b >> "%LOG%" 2>&1
dir "%BASE%\GNS*" /a:-d /b >> "%LOG%" 2>&1
echo. >> "%LOG%"

if exist "%TARGET%" (
  echo OK: Ya existe SistemaGestion.exe
  echo OK: Ya existe SistemaGestion.exe >> "%LOG%"
  goto crear_acceso
)

set SRC=

rem 1) Copias locales exactas o probables.
for %%P in (
  "%BASE%\SistemaGestion_original.exe"
  "%BASE%\SistemaGestion"
  "%BASE%\Sistema de Gestion.exe"
  "%BASE%\Sistema de Gestion"
  "%BASE%\GnsPersonal.exe"
  "%BASE%\GnsPersonal"
  "%BASE%\GNS Personal PRO.exe"
  "%BASE%\GNS Personal PRO"
) do (
  if not defined SRC if exist "%%~P" set SRC=%%~P
)

rem 2) Paquete generado en C:\SistemaGestion_Instalador.
for %%P in (
  "C:\SistemaGestion_Instalador\SistemaGestion_Paquete\SistemaGestion.exe"
  "C:\SistemaGestion_Instalador\SistemaGestion_Paquete\SistemaGestion"
  "C:\SistemaGestion_Instalador\SistemaGestion_Paquete\SistemaGestion_original.exe"
  "C:\SistemaGestion_Instalador\SistemaGestion_Paquete\GnsPersonal.exe"
) do (
  if not defined SRC if exist "%%~P" set SRC=%%~P
)

rem 3) Paquete en Escritorio.
for %%P in (
  "%USERPROFILE%\Desktop\sistema de gestion completo\SistemaGestion_Instalador\SistemaGestion_Paquete\SistemaGestion.exe"
  "%USERPROFILE%\Desktop\sistema de gestion completo\SistemaGestion_Instalador\SistemaGestion_Paquete\SistemaGestion"
  "%USERPROFILE%\Desktop\sistema de gestion completo\SistemaGestion_Instalador\SistemaGestion_Paquete\SistemaGestion_original.exe"
  "%USERPROFILE%\Desktop\sistema de gestion completo\SistemaGestion_Instalador\SistemaGestion_Paquete\GnsPersonal.exe"
) do (
  if not defined SRC if exist "%%~P" set SRC=%%~P
)

rem 4) Cualquier EXE en BASE que no sea uninstaller/update, como ultimo recurso.
if not defined SRC (
  for /f "delims=" %%F in ('dir "%BASE%\*.exe" /a:-d /b 2^>nul ^| findstr /i /v "uninst update reparar diagnostico instalar auditar buscar"') do (
    if not defined SRC set SRC=%BASE%\%%F
  )
)

if not defined SRC (
  echo ERROR: No encontre ejecutable para restaurar.
  echo ERROR: No encontre ejecutable para restaurar. >> "%LOG%"
  echo.
  echo Revise este log:
  echo %LOG%
  echo.
  type "%LOG%"
  pause
  exit /b 1
)

echo Fuente detectada:
echo %SRC%
echo Fuente detectada: %SRC% >> "%LOG%"

copy "%SRC%" "%TARGET%" /Y >> "%LOG%" 2>&1

if not exist "%TARGET%" (
  echo ERROR: No se pudo crear SistemaGestion.exe.
  echo ERROR: No se pudo crear SistemaGestion.exe. >> "%LOG%"
  type "%LOG%"
  pause
  exit /b 1
)

echo OK: SistemaGestion.exe restaurado.
echo OK: SistemaGestion.exe restaurado desde %SRC% >> "%LOG%"

:crear_acceso
echo.
echo Recreando acceso directo...
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
