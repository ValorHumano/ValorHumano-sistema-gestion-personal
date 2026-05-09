@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO

echo Reparando TODAS las rutas posibles de GNS Personal PRO - version 3...
echo.
echo Cierre GNS Personal PRO antes de ejecutar este archivo.
echo Ejecute este archivo como administrador.
echo.

call :FIX "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal"
call :FIX "HKLM\SOFTWARE\Grupo Net Software\Gns Personal"
call :FIX "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal"
call :FIX "HKCU\SOFTWARE\Grupo Net Software\Gns Personal"

echo.
echo === VERIFICACION FINAL ===
for %%K in ("HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKLM\SOFTWARE\Grupo Net Software\Gns Personal" "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKCU\SOFTWARE\Grupo Net Software\Gns Personal") do (
  echo.
  echo %%K
  reg query %%K /v PathAplicacion 2>nul
  reg query %%K /v BaseGral 2>nul
  reg query %%K /v BaseGralLstEmp 2>nul
)

echo.
echo Resultado esperado en los valores existentes:
echo C:\GNS Software\GNS Personal PRO\
echo.
echo Si aparece una ruta vieja de Downloads, copiar la pantalla y avisar.
echo.
pause
exit /b

:FIX
set KEY=%~1
echo Reparando: %KEY%
reg add "%KEY%" /v PathAplicacion /t REG_SZ /d "%BASE%\\" /f >nul
reg add "%KEY%" /v BaseGral /t REG_SZ /d "%BASE%\\" /f >nul
reg add "%KEY%" /v BaseGralLstEmp /t REG_SZ /d "%BASE%\\" /f >nul
exit /b
