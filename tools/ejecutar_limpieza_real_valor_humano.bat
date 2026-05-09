@echo off
setlocal

set SCRIPT_DIR=%~dp0
set VBS=%SCRIPT_DIR%limpiar_base_valor_humano.vbs
set CSCRIPT32=C:\Windows\SysWOW64\cscript.exe

echo ============================================================
echo LIMPIEZA REAL DE DATOS DEMO - VALOR HUMANO
echo ============================================================
echo.
echo ATENCION: Este proceso elimina datos demo de empleados,
echo contratos, liquidaciones, legajos, licencias, MTSS y pagos.
echo.
echo Antes de borrar, el script crea un respaldo automatico en:
echo C:\GNS Software\GNS Personal PRO\Valor Humano\Respaldos
echo.
echo Cierre GNS Personal PRO antes de continuar.
echo.
choice /C SN /M "Desea ejecutar la limpieza real ahora"
if errorlevel 2 (
  echo Operacion cancelada por el usuario.
  pause
  exit /b 0
)

if not exist "%VBS%" (
  echo ERROR: No se encontro "%VBS%"
  echo Guarde este BAT en la misma carpeta que limpiar_base_valor_humano.vbs
  pause
  exit /b 1
)

"%CSCRIPT32%" //nologo "%VBS%"

echo.
echo Si termino correctamente, abra GNS Personal PRO y verifique:
echo - Empresa Actual: Valor Humano
echo - Fichas Personales sin empleados demo
echo - Datos de Empresa editables
echo.
pause
