@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set OUT=%BASE%\reparacion_gns_v4_virtualstore.txt

echo REPARACION GNS PERSONAL PRO - V4 VIRTUALSTORE > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo Cerrando posibles procesos GnsPersonal.exe...
taskkill /IM GnsPersonal.exe /F >nul 2>&1

echo Aplicando rutas locales en claves normales y VirtualStore...

call :FIX "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal"
call :FIX "HKLM\SOFTWARE\Grupo Net Software\Gns Personal"
call :FIX "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal"
call :FIX "HKCU\SOFTWARE\Grupo Net Software\Gns Personal"
call :FIX "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal"
call :FIX "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Grupo Net Software\Gns Personal"

echo. >> "%OUT%"
echo === VERIFICACION DE CLAVES === >> "%OUT%"
for %%K in ("HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKLM\SOFTWARE\Grupo Net Software\Gns Personal" "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKCU\SOFTWARE\Grupo Net Software\Gns Personal" "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Grupo Net Software\Gns Personal") do (
  echo. >> "%OUT%"
  echo %%K >> "%OUT%"
  reg query %%K /s >> "%OUT%" 2>&1
)

echo. >> "%OUT%"
echo === VIRTUALSTORE DE ARCHIVOS === >> "%OUT%"
if exist "%LOCALAPPDATA%\VirtualStore\GNS Software\GNS Personal PRO" (
  echo EXISTE: "%LOCALAPPDATA%\VirtualStore\GNS Software\GNS Personal PRO" >> "%OUT%"
  dir "%LOCALAPPDATA%\VirtualStore\GNS Software\GNS Personal PRO" /b >> "%OUT%" 2>&1
) else (
  echo No existe VirtualStore de archivos para GNS Personal PRO. >> "%OUT%"
)

echo. >> "%OUT%"
echo === ACCESO DIRECTO URL === >> "%OUT%"
if exist "%BASE%\GNS Personal PRO.url" type "%BASE%\GNS Personal PRO.url" >> "%OUT%"

echo. >> "%OUT%"
echo === RUTA EXACTA DEL EJECUTABLE LOCAL === >> "%OUT%"
if exist "%BASE%\GnsPersonal.exe" echo "%BASE%\GnsPersonal.exe" >> "%OUT%"

echo. >> "%OUT%"
echo Reparacion V4 terminada. >> "%OUT%"

echo Reparacion V4 terminada.
echo Reporte generado en:
echo "%OUT%"
echo.
echo Ahora ejecute tools\abrir_gns_local.bat para abrir SI O SI el exe local.
pause
exit /b

:FIX
set KEY=%~1
reg add "%KEY%" /v PathAplicacion /t REG_SZ /d "%BASE%\\" /f >nul
reg add "%KEY%" /v BaseGral /t REG_SZ /d "%BASE%\\" /f >nul
reg add "%KEY%" /v BaseGralLstEmp /t REG_SZ /d "%BASE%\\" /f >nul
echo Reparada: %KEY% >> "%OUT%"
exit /b
