@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set OUT=%BASE%\busqueda_ruta_vieja_gns_v2.txt

echo BUSQUEDA RAPIDA DE RUTA VIEJA - GNS PERSONAL PRO > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === CLAVES GNS ESPECIFICAS === >> "%OUT%"
for %%K in ("HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKLM\SOFTWARE\Grupo Net Software\Gns Personal" "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" "HKCU\SOFTWARE\Grupo Net Software\Gns Personal") do (
  echo. >> "%OUT%"
  echo %%K >> "%OUT%"
  reg query %%K /s >> "%OUT%" 2>&1
)

echo. >> "%OUT%"
echo === BUSQUEDA EN ARCHIVOS LIVIANOS DE CONFIGURACION === >> "%OUT%"
cd /d "%BASE%"
for %%F in (*.ini *.txt *.cfg *.dat *.url) do (
  echo Revisando %%F >> "%OUT%"
  findstr /i /n "Downloads valor-humano-videos-livianos GNS_Personal_PRO_Paquete_PRO" "%%F" >> "%OUT%" 2>nul
)

echo. >> "%OUT%"
echo === BUSQUEDA EN SUBCARPETAS SOLO INI TXT CFG DAT URL === >> "%OUT%"
for /r "%BASE%" %%F in (*.ini *.txt *.cfg *.dat *.url) do (
  findstr /i /n "Downloads valor-humano-videos-livianos GNS_Personal_PRO_Paquete_PRO" "%%F" >nul 2>nul
  if not errorlevel 1 (
    echo. >> "%OUT%"
    echo ARCHIVO: %%F >> "%OUT%"
    findstr /i /n "Downloads valor-humano-videos-livianos GNS_Personal_PRO_Paquete_PRO" "%%F" >> "%OUT%" 2>nul
  )
)

echo. >> "%OUT%"
echo === ARCHIVOS QUE PODRIAN CONTENER CONFIGURACION === >> "%OUT%"
dir "%BASE%\*" /a:-d /b >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo Busqueda rapida terminada. Archivo generado: >> "%OUT%"
echo %OUT% >> "%OUT%"

echo Busqueda rapida terminada.
echo Archivo generado: "%OUT%"
echo Pegue ese contenido en ChatGPT.
pause
