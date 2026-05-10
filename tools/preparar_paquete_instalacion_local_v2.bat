@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set OUTROOT=C:\SistemaGestion_Instalador
set PKG=%OUTROOT%\SistemaGestion_Paquete
set ZIP=%OUTROOT%\SistemaGestion_Paquete.zip
set MANIFEST=%PKG%\MANIFEST_INSTALACION.txt

echo ============================================================
echo PREPARAR PAQUETE FINAL - SISTEMA DE GESTION
echo ============================================================
echo.
echo Este proceso arma un ZIP instalable desde la PC actual.
echo No sube bases ni ejecutables a GitHub.
echo.
echo Origen:  %BASE%
echo Destino: %ZIP%
echo.
pause

if not exist "%BASE%\SistemaGestion.exe" (
  echo ERROR: No existe SistemaGestion.exe en %BASE%
  pause
  exit /b 1
)

if not exist "%BASE%\Usuarios.mdb" (
  echo ERROR: No existe Usuarios.mdb en %BASE%
  pause
  exit /b 1
)

if not exist "%BASE%\Valor Humano\Personal.mdb" (
  echo ERROR: No existe Valor Humano\Personal.mdb
  pause
  exit /b 1
)

if exist "%PKG%" rmdir /s /q "%PKG%"
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
mkdir "%PKG%"

echo Copiando instalacion funcional...
robocopy "%BASE%" "%PKG%" /E /XD "_Backup*" "_Demos_Backup" "_Branding_Backup" "_Empresas_Ocultas" "Respaldos" /XF "*.ldb" "*.log" "diagnostico_*.txt" "analisis_*.txt" "auditoria_*.txt" "busqueda_*.txt" "correccion_*.txt" "estructura_base_*.txt" "simulacion_*.txt" "verificacion_*.txt" "limpieza_*.txt" >nul

if not exist "%PKG%\Valor Humano\Respaldos" mkdir "%PKG%\Valor Humano\Respaldos"
if not exist "%PKG%\Valor Humano\HistorialLaboral" mkdir "%PKG%\Valor Humano\HistorialLaboral"
if not exist "%PKG%\Valor Humano\imgEmpleados" mkdir "%PKG%\Valor Humano\imgEmpleados"
if not exist "%PKG%\Valor Humano\MTSS" mkdir "%PKG%\Valor Humano\MTSS"
if not exist "%PKG%\Valor Humano\Reportes" mkdir "%PKG%\Valor Humano\Reportes"

echo Copiando instaladores/verificadores del repo al paquete...
copy "%~dp0instalar_sistema_gestion_nueva_pc_v2.bat" "%PKG%\instalar_sistema_gestion_nueva_pc_v2.bat" >nul 2>&1
copy "%~dp0verificar_instalacion_sistema_gestion.vbs" "%PKG%\verificar_instalacion_sistema_gestion.vbs" >nul 2>&1

echo Generando manifiesto...
echo MANIFEST INSTALACION SISTEMA DE GESTION > "%MANIFEST%"
echo Fecha: %DATE% %TIME% >> "%MANIFEST%"
echo Origen: %BASE% >> "%MANIFEST%"
echo. >> "%MANIFEST%"
echo ARCHIVOS CRITICOS >> "%MANIFEST%"
if exist "%PKG%\SistemaGestion.exe" echo OK SistemaGestion.exe >> "%MANIFEST%" else echo FALTA SistemaGestion.exe >> "%MANIFEST%"
if exist "%PKG%\Usuarios.mdb" echo OK Usuarios.mdb >> "%MANIFEST%" else echo FALTA Usuarios.mdb >> "%MANIFEST%"
if exist "%PKG%\Configura.ini" echo OK Configura.ini >> "%MANIFEST%" else echo FALTA Configura.ini >> "%MANIFEST%"
if exist "%PKG%\ConfiguraSis.ini" echo OK ConfiguraSis.ini >> "%MANIFEST%" else echo FALTA ConfiguraSis.ini >> "%MANIFEST%"
if exist "%PKG%\ListEmpresas.ini" echo OK ListEmpresas.ini >> "%MANIFEST%" else echo FALTA ListEmpresas.ini >> "%MANIFEST%"
if exist "%PKG%\ListEmpresas" echo OK ListEmpresas >> "%MANIFEST%" else echo FALTA ListEmpresas >> "%MANIFEST%"
if exist "%PKG%\Valor Humano\Personal.mdb" echo OK Valor Humano\Personal.mdb >> "%MANIFEST%" else echo FALTA Valor Humano\Personal.mdb >> "%MANIFEST%"
if exist "%PKG%\Generica" echo OK Generica >> "%MANIFEST%" else echo AVISO FALTA Generica >> "%MANIFEST%"
echo. >> "%MANIFEST%"
echo EJECUTABLES >> "%MANIFEST%"
dir "%PKG%\*.exe" /b >> "%MANIFEST%" 2>nul
echo. >> "%MANIFEST%"
echo DEPENDENCIAS OCX/DLL LOCALES >> "%MANIFEST%"
dir "%PKG%\*.ocx" /b >> "%MANIFEST%" 2>nul
dir "%PKG%\*.dll" /b >> "%MANIFEST%" 2>nul
echo. >> "%MANIFEST%"
echo LISTADO COMPLETO >> "%MANIFEST%"
dir "%PKG%" /s /b >> "%MANIFEST%"

echo Creando ZIP final...
if exist "%ZIP%" del "%ZIP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%PKG%\*' -DestinationPath '%ZIP%' -Force"

if not exist "%ZIP%" (
  echo ERROR: No se pudo crear el ZIP.
  pause
  exit /b 1
)

echo.
echo PAQUETE CREADO CORRECTAMENTE:
echo %ZIP%
echo.
echo Este ZIP es el instalador transportable para otra PC.
echo En la otra PC: extraer ZIP y ejecutar instalar_sistema_gestion_nueva_pc_v2.bat como administrador.
echo.
pause
