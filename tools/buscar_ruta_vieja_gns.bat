@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set OUT=%BASE%\busqueda_ruta_vieja_gns.txt

echo BUSQUEDA DE RUTA VIEJA - GNS PERSONAL PRO > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === BUSQUEDA EN REGISTRO: valor-humano-videos-livianos === >> "%OUT%"
reg query HKLM /f "valor-humano-videos-livianos" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"
reg query HKCU /f "valor-humano-videos-livianos" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"

echo === BUSQUEDA EN REGISTRO: GNS_Personal_PRO_Paquete_PRO === >> "%OUT%"
reg query HKLM /f "GNS_Personal_PRO_Paquete_PRO" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"
reg query HKCU /f "GNS_Personal_PRO_Paquete_PRO" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"

echo === BUSQUEDA EN ARCHIVOS DE CONFIGURACION === >> "%OUT%"
cd /d "%BASE%"
findstr /s /i /m "valor-humano-videos-livianos GNS_Personal_PRO_Paquete_PRO Downloads" *.ini *.txt *.cfg *.dat *.url >> "%OUT%" 2>&1
echo. >> "%OUT%"

echo === CONTENIDO DEL ACCESO DIRECTO URL SI EXISTE === >> "%OUT%"
if exist "%BASE%\GNS Personal PRO.url" type "%BASE%\GNS Personal PRO.url" >> "%OUT%"
echo. >> "%OUT%"

echo === VERIFICACION DE REGISTRO GNS === >> "%OUT%"
reg query "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"
reg query "HKLM\SOFTWARE\Grupo Net Software\Gns Personal" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"
reg query "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"
reg query "HKCU\SOFTWARE\Grupo Net Software\Gns Personal" /s >> "%OUT%" 2>&1
echo. >> "%OUT%"

echo Busqueda terminada. Archivo generado:
echo "%OUT%"
echo.
echo Pegue el contenido de ese archivo en ChatGPT.
pause
