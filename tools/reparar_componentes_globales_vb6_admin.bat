@echo off
setlocal EnableExtensions

net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Solicitando permisos de administrador...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set BASE=C:\GNS Software\GNS Personal PRO
set LOG=%BASE%\reparar_componentes_globales_vb6_admin_log.txt
set BKP=%BASE%\_Backup_Componentes_Globales

echo ============================================================
echo REPARAR COMPONENTES GLOBALES VB6 - SISTEMA DE GESTION
echo ============================================================
echo.
echo Ejecutando como Administrador.
echo Este proceso copia a la carpeta del sistema los OCX/DLL encontrados
echo en Windows y los registra con regsvr32 de SysWOW64.
echo No toca bases, usuarios, licencias ni liquidaciones.
echo.
pause

if not exist "%BASE%" (
  echo ERROR: No existe %BASE%
  pause
  exit /b 1
)
if not exist "%BKP%" mkdir "%BKP%"

echo REPARAR COMPONENTES GLOBALES VB6 %DATE% %TIME% > "%LOG%"
echo BASE=%BASE% >> "%LOG%"
echo. >> "%LOG%"

call :copiar_y_registrar msadodc.ocx
call :copiar_y_registrar comdlg32.ocx
call :copiar_y_registrar mscomct2.ocx
call :copiar_y_registrar msflxgrd.ocx
call :copiar_y_registrar tabctl32.ocx
call :copiar_y_registrar vbalProgBar6.ocx
call :copiar_y_registrar vbalIml6.ocx
call :copiar_y_registrar vbaListView6.ocx
call :copiar_y_registrar vbalTreeView6.ocx
call :copiar_y_registrar ssdw3bo.ocx
call :copiar_y_registrar AniGIF.ocx
call :copiar_y_registrar CuadradoColores.ocx
call :copiar_y_registrar mswinsck.ocx
call :copiar_y_registrar MsComCtl.ocx
call :copiar_y_registrar XceedZip.dll
call :copiar_y_registrar CRViewer.dll
call :copiar_y_registrar crviewer9.dll
call :copiar_y_registrar BtnDibu4.ocx
call :copiar_y_registrar OtrosObjZinco.ocx
call :copiar_y_registrar ZincoGrid.ocx
call :copiar_y_registrar PaComunicar.ocx
call :copiar_y_registrar ControlParaRep.ocx
call :copiar_y_registrar cPopMenuZinco.ocx
call :copiar_y_registrar DllConexion.dll
call :copiar_y_registrar DllConexion4.dll
call :copiar_y_registrar LibGeneral.dll
call :copiar_y_registrar LibGeneral4.dll
call :copiar_y_registrar FuncionesVarias.dll
call :copiar_y_registrar FuncionesVarias4.dll
call :copiar_y_registrar ArchivosFormateados4.dll
call :copiar_y_registrar ArchivosFormateadosPRO.dll

echo. >> "%LOG%"
echo VERIFICACION LOCAL FINAL >> "%LOG%"
for %%F in (msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx tabctl32.ocx vbalProgBar6.ocx vbalIml6.ocx vbaListView6.ocx vbalTreeView6.ocx ssdw3bo.ocx AniGIF.ocx CuadradoColores.ocx mswinsck.ocx MsComCtl.ocx XceedZip.dll CRViewer.dll crviewer9.dll BtnDibu4.ocx OtrosObjZinco.ocx ZincoGrid.ocx PaComunicar.ocx ControlParaRep.ocx cPopMenuZinco.ocx DllConexion.dll DllConexion4.dll LibGeneral.dll LibGeneral4.dll FuncionesVarias.dll FuncionesVarias4.dll ArchivosFormateados4.dll ArchivosFormateadosPRO.dll) do (
  if exist "%BASE%\%%F" (
    echo OK LOCAL: %%F >> "%LOG%"
  ) else (
    echo FALTA LOCAL: %%F >> "%LOG%"
  )
)

echo.
echo Reparacion terminada.
echo Log:
echo %LOG%
echo.
echo Ahora abra el sistema y pruebe el modulo que fallaba.
echo Si vuelve a fallar, pegue el nuevo error y este log.
echo.
pause
exit /b 0

:copiar_y_registrar
set FILE=%~1
set SRC=

if exist "%BASE%\%FILE%" set SRC=%BASE%\%FILE%
if not defined SRC if exist "C:\Windows\SysWOW64\%FILE%" set SRC=C:\Windows\SysWOW64\%FILE%
if not defined SRC if exist "C:\Windows\SysWOW64\Redist\MS\System\%FILE%" set SRC=C:\Windows\SysWOW64\Redist\MS\System\%FILE%
if not defined SRC if exist "C:\Windows\System32\%FILE%" set SRC=C:\Windows\System32\%FILE%

if not defined SRC (
  echo FALTA: %FILE%
  echo FALTA: %FILE% >> "%LOG%"
  goto :eof
)

echo Procesando %FILE% desde %SRC%
echo Procesando %FILE% desde %SRC% >> "%LOG%"

if exist "%BASE%\%FILE%" copy "%BASE%\%FILE%" "%BKP%\%FILE%.bak" /Y >> "%LOG%" 2>&1
if /I not "%SRC%"=="%BASE%\%FILE%" copy "%SRC%" "%BASE%\%FILE%" /Y >> "%LOG%" 2>&1

if exist "%BASE%\%FILE%" (
  C:\Windows\SysWOW64\regsvr32.exe /s "%BASE%\%FILE%"
  echo Resultado regsvr32 %FILE%: %errorlevel% >> "%LOG%"
) else (
  echo ERROR: no quedo local %FILE% >> "%LOG%"
)

goto :eof
