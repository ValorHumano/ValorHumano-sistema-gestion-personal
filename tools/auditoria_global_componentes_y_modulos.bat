@echo off
setlocal EnableExtensions EnableDelayedExpansion

set BASE=C:\GNS Software\GNS Personal PRO
set OUT=%BASE%\auditoria_global_componentes_y_modulos.txt

echo ============================================================
echo AUDITORIA GLOBAL DE COMPONENTES Y MODULOS
echo ============================================================
echo.
echo Este proceso NO modifica nada. Solo busca componentes faltantes,
echo utilitarios y posibles causas de errores de modulos.
echo.
pause

if not exist "%BASE%" mkdir "%BASE%"

echo AUDITORIA GLOBAL DE COMPONENTES Y MODULOS - SISTEMA DE GESTION > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo Base: %BASE% >> "%OUT%"
echo. >> "%OUT%"

set COMPONENTES=msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx tabctl32.ocx vbalProgBar6.ocx vbalIml6.ocx vbaListView6.ocx vbalTreeView6.ocx ssdw3bo.ocx AniGIF.ocx CuadradoColores.ocx BtnDibu4.ocx OtrosObjZinco.ocx ZincoGrid.ocx PaComunicar.ocx ControlParaRep.ocx cPopMenuZinco.ocx mswinsck.ocx MsComCtl.ocx crviewer9.dll CRViewer.dll XceedZip.dll DllConexion.dll DllConexion4.dll LibGeneral.dll LibGeneral4.dll FuncionesVarias.dll FuncionesVarias4.dll ArchivosFormateados4.dll ArchivosFormateadosPRO.dll VB6STKIT.DLL

echo === 1) COMPONENTES OCX/DLL BUSCADOS === >> "%OUT%"
for %%F in (%COMPONENTES%) do echo %%F >> "%OUT%"
echo. >> "%OUT%"

echo === 2) PRESENCIA EN UBICACIONES DIRECTAS === >> "%OUT%"
for %%F in (%COMPONENTES%) do (
  echo. >> "%OUT%"
  echo Archivo: %%F >> "%OUT%"
  set FOUND=0
  if exist "%BASE%\%%F" echo LOCAL: %BASE%\%%F >> "%OUT%" & set FOUND=1
  if exist "C:\Windows\SysWOW64\%%F" echo SYSWOW64: C:\Windows\SysWOW64\%%F >> "%OUT%" & set FOUND=1
  if exist "C:\Windows\System32\%%F" echo SYSTEM32: C:\Windows\System32\%%F >> "%OUT%" & set FOUND=1
  if exist "C:\Windows\SysWOW64\Redist\MS\System\%%F" echo REDIST: C:\Windows\SysWOW64\Redist\MS\System\%%F >> "%OUT%" & set FOUND=1
  if !FOUND!==0 echo FALTA_DIRECTO: %%F >> "%OUT%"
)

echo. >> "%OUT%"
echo === 3) BUSQUEDA EN CARPETAS PROBABLES === >> "%OUT%"
for %%R in ("C:\GNS Software" "%USERPROFILE%\Downloads" "%USERPROFILE%\Desktop" "%USERPROFILE%\Documents" "C:\Program Files" "C:\Program Files (x86)") do (
  if exist %%~R (
    echo. >> "%OUT%"
    echo --- %%~R --- >> "%OUT%"
    for %%F in (%COMPONENTES%) do (
      dir "%%~R\%%F" /s /b 2>nul >> "%OUT%"
    )
  )
)

echo. >> "%OUT%"
echo === 4) BUSQUEDA DENTRO DE ZIP EN CARPETAS PROBABLES === >> "%OUT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$targets='%COMPONENTES%'.Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries); $roots=@('C:\GNS Software',$env:USERPROFILE+'\Downloads',$env:USERPROFILE+'\Desktop',$env:USERPROFILE+'\Documents'); Add-Type -AssemblyName System.IO.Compression.FileSystem; foreach($r in $roots){ if(Test-Path $r){ Get-ChildItem -Path $r -Recurse -Filter *.zip -ErrorAction SilentlyContinue | ForEach-Object { $zip=$_.FullName; try { $z=[IO.Compression.ZipFile]::OpenRead($zip); foreach($e in $z.Entries){ foreach($t in $targets){ if($e.FullName.ToLower().EndsWith($t.ToLower())){ 'ZIP: '+$zip+' -> '+$e.FullName | Add-Content -Path '%OUT%' } } }; $z.Dispose() } catch {} } } }"

echo. >> "%OUT%"
echo === 5) UTILITARIOS REFERENCIADOS === >> "%OUT%"
set UTILS=Utiles\ImportaHoras.exe Utiles\ImportadorDeHL.exe Utiles\IG\ImportadorGeneral.exe Utiles\DatosWeb\ModuloWeb.exe Utiles\ImportarDatos.exe Utiles\gennum.jar Utiles\CajaBancaria\Caja Bancaria.exe Utiles\AbitabRecibos.exe Proyecciones.exe
for %%U in (%UTILS%) do (
  if exist "%BASE%\%%U" (
    echo OK: %%U >> "%OUT%"
  ) else (
    echo FALTA: %%U >> "%OUT%"
  )
)

echo. >> "%OUT%"
echo === 6) CARPETAS OPERATIVAS === >> "%OUT%"
for %%D in ("%BASE%\Valor Humano" "%BASE%\Valor Humano\Respaldos" "%BASE%\Valor Humano\HistorialLaboral" "%BASE%\Valor Humano\HistoriaLaboral" "%BASE%\Valor Humano\imgEmpleados" "%BASE%\Valor Humano\MTSS" "%BASE%\Valor Humano\Reportes" "C:\GnsTmp" "C:\MTSS - GNS" "C:\BPS - GNS" "C:\FOCER - GNS") do (
  if exist "%%~D" echo OK: %%~D >> "%OUT%" else echo FALTA: %%~D >> "%OUT%"
)

echo. >> "%OUT%"
echo === 7) RESUMEN DE FALTANTES DIRECTOS === >> "%OUT%"
for %%F in (%COMPONENTES%) do (
  if not exist "%BASE%\%%F" if not exist "C:\Windows\SysWOW64\%%F" if not exist "C:\Windows\System32\%%F" if not exist "C:\Windows\SysWOW64\Redist\MS\System\%%F" echo FALTA_DIRECTO: %%F >> "%OUT%"
)

echo. >> "%OUT%"
echo FIN >> "%OUT%"

echo.
echo Reporte generado:
echo %OUT%
echo.
echo Pegue ese archivo en ChatGPT.
pause
