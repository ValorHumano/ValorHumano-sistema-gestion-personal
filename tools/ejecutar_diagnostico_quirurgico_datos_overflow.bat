@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set PS1=%~dp0diagnostico_quirurgico_datos_overflow_vb6.ps1
set LOG=%BASE%\ejecutar_diagnostico_quirurgico_datos_overflow_log.txt

if not exist "%BASE%" mkdir "%BASE%"

echo ============================================================
echo DIAGNOSTICO QUIRURGICO DATOS / OVERFLOW VB6
echo ============================================================
echo.
echo Este chequeo es de solo lectura.
echo Busca datos que puedan provocar Error 6 Desbordamiento
echo u otros fallos al abrir pantallas como Cargos.
echo.
echo No modifica bases, usuarios, licencias ni liquidaciones.
echo.
pause

echo INICIO %DATE% %TIME% > "%LOG%"

if not exist "%PS1%" (
  echo ERROR: No encontre el archivo PS1:
  echo %PS1%
  echo ERROR: No encontre PS1 %PS1% >> "%LOG%"
  echo.
  echo Descargue tambien diagnostico_quirurgico_datos_overflow_vb6.ps1
  echo y pongalo en la misma carpeta que este BAT.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" >> "%LOG%" 2>&1
set EXITCODE=%ERRORLEVEL%

echo. >> "%LOG%"
echo PowerShell exit code: %EXITCODE% >> "%LOG%"

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
echo Reportes generados en:
echo %BASE%
echo.
dir "%BASE%\diagnostico_quirurgico_datos_overflow_*.txt" /b /o-d
echo.
echo Pegue el TXT mas reciente en ChatGPT.
echo.
pause
