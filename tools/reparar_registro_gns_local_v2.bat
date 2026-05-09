@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set KEY=HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal

echo Reparando rutas locales de GNS Personal PRO - version 2...
echo.
echo Esta version corrige el problema de rutas que terminan en barra invertida.
echo.

reg add "%KEY%" /v PathAplicacion /t REG_SZ /d "%BASE%\\" /f
reg add "%KEY%" /v BaseGral /t REG_SZ /d "%BASE%\\" /f
reg add "%KEY%" /v BaseGralLstEmp /t REG_SZ /d "%BASE%\\" /f

echo.
echo Valores actuales:
reg query "%KEY%" /v PathAplicacion
reg query "%KEY%" /v BaseGral
reg query "%KEY%" /v BaseGralLstEmp

echo.
echo Resultado esperado:
echo C:\GNS Software\GNS Personal PRO\
echo.
echo Si NO aparece texto adicional como /f al final de las rutas, esta correcto.
echo.
pause
