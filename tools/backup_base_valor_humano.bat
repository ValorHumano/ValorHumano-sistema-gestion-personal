@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EMPRESA=%BASE%\Valor Humano
set ORIGEN=%EMPRESA%\Personal.mdb
set DESTINO_DIR=%EMPRESA%\Respaldos

for /f "tokens=1-3 delims=/" %%a in ("%DATE%") do (
  set DD=%%a
  set MM=%%b
  set YY=%%c
)
for /f "tokens=1-3 delims=:., " %%a in ("%TIME%") do (
  set HH=%%a
  set MN=%%b
  set SS=%%c
)
set HH=%HH: =0%
set BACKUP=%DESTINO_DIR%\Personal_BACKUP_ANTES_DE_LIMPIAR_%YY%%MM%%DD%_%HH%%MN%%SS%.mdb

echo Creando respaldo de la base Valor Humano...
echo Origen:  "%ORIGEN%"
echo Destino: "%BACKUP%"
echo.

if not exist "%ORIGEN%" (
  echo ERROR: No existe la base original.
  echo Revise que exista: "%ORIGEN%"
  pause
  exit /b 1
)

if not exist "%DESTINO_DIR%" mkdir "%DESTINO_DIR%"

copy "%ORIGEN%" "%BACKUP%" >nul
if errorlevel 1 (
  echo ERROR: No se pudo crear el respaldo.
  pause
  exit /b 1
)

echo Respaldo creado correctamente.
echo.
dir "%BACKUP%"
echo.
echo IMPORTANTE: No borre este archivo. Es el punto de retorno antes de limpiar datos demo.
pause
