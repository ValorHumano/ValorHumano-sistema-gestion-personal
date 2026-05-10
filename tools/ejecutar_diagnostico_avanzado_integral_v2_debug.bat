@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set LOG=%BASE%\ejecutar_diagnostico_avanzado_integral_v2_debug_log.txt
set PS1_SAME=%~dp0diagnostico_avanzado_integral_sistema_gestion.ps1
set PS1_BASE=%BASE%\diagnostico_avanzado_integral_sistema_gestion.ps1

if not exist "%BASE%" mkdir "%BASE%"

echo ============================================================
echo DIAGNOSTICO AVANZADO INTEGRAL V2 DEBUG
echo ============================================================
echo.
echo Esta version NO deberia cerrarse sola.
echo Si hay error, queda registrado en:
echo %LOG%
echo.
echo Carpeta del BAT:
echo %~dp0
echo.
pause

echo INICIO %DATE% %TIME% > "%LOG%"
echo BASE=%BASE% >> "%LOG%"
echo BAT=%~f0 >> "%LOG%"
echo PS1_SAME=%PS1_SAME% >> "%LOG%"
echo PS1_BASE=%PS1_BASE% >> "%LOG%"
echo. >> "%LOG%"

set PS1=
if exist "%PS1_SAME%" set PS1=%PS1_SAME%
if not defined PS1 if exist "%PS1_BASE%" set PS1=%PS1_BASE%

if not defined PS1 (
  echo ERROR: No encontre diagnostico_avanzado_integral_sistema_gestion.ps1
  echo ERROR: No encontre diagnostico_avanzado_integral_sistema_gestion.ps1 >> "%LOG%"
  echo.
  echo SOLUCION:
  echo 1. Descargue tambien diagnostico_avanzado_integral_sistema_gestion.ps1
  echo 2. Ponga el .ps1 en la misma carpeta que este .bat
  echo    o copielo en:
  echo    %BASE%
  echo.
  echo Log:
  echo %LOG%
  pause
  exit /b 1
)

echo Usando PS1:
echo %PS1%
echo Usando PS1=%PS1% >> "%LOG%"
echo. >> "%LOG%"

echo Ejecutando PowerShell...
echo Ejecutando PowerShell... >> "%LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" >> "%LOG%" 2>&1
set PS_EXIT=%ERRORLEVEL%

echo. >> "%LOG%"
echo PowerShell exit code: %PS_EXIT% >> "%LOG%"
echo.
echo PowerShell termino con codigo: %PS_EXIT%

if not "%PS_EXIT%"=="0" (
  echo.
  echo Hubo un error. Abro el log abajo:
  echo ------------------------------------------------------------
  type "%LOG%"
  echo ------------------------------------------------------------
  echo.
  pause
  exit /b %PS_EXIT%
)

echo.
echo Buscando reportes generados...
echo Buscando reportes generados... >> "%LOG%"
dir "%BASE%\diagnostico_avanzado_integral_*.txt" /b /o-d >> "%LOG%" 2>&1
dir "%BASE%\diagnostico_avanzado_integral_*.html" /b /o-d >> "%LOG%" 2>&1

echo.
echo FINALIZADO OK.
echo Revise los reportes en:
echo %BASE%
echo.
echo Tambien puede pegarme este log:
echo %LOG%
echo.
pause
