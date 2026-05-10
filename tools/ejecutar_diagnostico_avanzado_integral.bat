@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set PS1=%~dp0diagnostico_avanzado_integral_sistema_gestion.ps1

echo ============================================================
echo DIAGNOSTICO AVANZADO INTEGRAL - SISTEMA DE GESTION
echo ============================================================
echo.
echo Este chequeo es de solo lectura.
echo No modifica bases, usuarios, licencias ni liquidaciones.
echo Genera reporte TXT y HTML en:
echo %BASE%
echo.
pause

if not exist "%PS1%" (
  echo ERROR: No se encontro:
  echo %PS1%
  echo.
  echo Descargue tambien diagnostico_avanzado_integral_sistema_gestion.ps1
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"

echo.
echo Finalizado.
echo Busque los archivos diagnostico_avanzado_integral_*.txt y *.html en:
echo %BASE%
echo.
pause
