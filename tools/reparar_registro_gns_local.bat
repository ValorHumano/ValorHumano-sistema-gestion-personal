@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO\
set KEY=HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal

echo Reparando rutas locales de GNS Personal PRO...
echo.

reg add "%KEY%" /v PathAplicacion /t REG_SZ /d "%BASE%" /f
reg add "%KEY%" /v BaseGral /t REG_SZ /d "%BASE%" /f
reg add "%KEY%" /v BaseGralLstEmp /t REG_SZ /d "%BASE%" /f

echo.
echo Valores actuales:
reg query "%KEY%" /v PathAplicacion
reg query "%KEY%" /v BaseGral
reg query "%KEY%" /v BaseGralLstEmp

echo.
echo Reparacion terminada.
echo Cierre esta ventana y abra nuevamente GnsPersonal.exe.
pause
