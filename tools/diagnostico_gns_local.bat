@echo off
setlocal
set BASE=C:\GNS Software\GNS Personal PRO
set OUT=%BASE%\diagnostico_gns_local.txt

echo DIAGNOSTICO GNS PERSONAL PRO - VALOR HUMANO > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo Usuario: %USERNAME% >> "%OUT%"
echo Equipo: %COMPUTERNAME% >> "%OUT%"
echo. >> "%OUT%"

echo === RUTAS PRINCIPALES === >> "%OUT%"
if exist "%BASE%" (echo OK BASE: "%BASE%" >> "%OUT%") else (echo FALTA BASE: "%BASE%" >> "%OUT%")
if exist "%BASE%\GnsPersonal.exe" (echo OK GnsPersonal.exe >> "%OUT%") else (echo FALTA GnsPersonal.exe >> "%OUT%")
if exist "%BASE%\Usuarios.mdb" (echo OK Usuarios.mdb >> "%OUT%") else (echo FALTA Usuarios.mdb >> "%OUT%")
if exist "%BASE%\Configura.ini" (echo OK Configura.ini >> "%OUT%") else (echo FALTA Configura.ini >> "%OUT%")
if exist "%BASE%\ConfiguraSis.ini" (echo OK ConfiguraSis.ini >> "%OUT%") else (echo FALTA ConfiguraSis.ini >> "%OUT%")
if exist "%BASE%\ListEmpresas.ini" (echo OK ListEmpresas.ini >> "%OUT%") else (echo FALTA ListEmpresas.ini >> "%OUT%")
if exist "%BASE%\Valor Humano" (echo OK carpeta Valor Humano >> "%OUT%") else (echo FALTA carpeta Valor Humano >> "%OUT%")
if exist "%BASE%\Valor Humano\Personal.mdb" (echo OK Valor Humano\Personal.mdb >> "%OUT%") else (echo FALTA Valor Humano\Personal.mdb >> "%OUT%")

echo. >> "%OUT%"
echo === LISTEMPRESAS === >> "%OUT%"
if exist "%BASE%\ListEmpresas.ini" type "%BASE%\ListEmpresas.ini" >> "%OUT%"

echo. >> "%OUT%"
echo === REGISTRO HKLM 32 BITS === >> "%OUT%"
reg query "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === REGISTRO HKLM NORMAL === >> "%OUT%"
reg query "HKLM\SOFTWARE\Grupo Net Software\Gns Personal" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === REGISTRO HKCU NORMAL === >> "%OUT%"
reg query "HKCU\SOFTWARE\Grupo Net Software\Gns Personal" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === DEPENDENCIAS PRINCIPALES === >> "%OUT%"
for %%F in (BtnDibu4.ocx OtrosObjZinco.ocx ZincoGrid.ocx PaComunicar.ocx ControlParaRep.ocx crviewer9.dll DllConexion.dll DllConexion4.dll LibGeneral.dll FuncionesVarias.dll) do (
  if exist "%BASE%\%%F" (echo OK %%F >> "%OUT%") else (echo FALTA %%F >> "%OUT%")
)

echo. >> "%OUT%"
echo Diagnostico generado en "%OUT%"
echo Pegue el contenido de ese archivo en ChatGPT.
pause
