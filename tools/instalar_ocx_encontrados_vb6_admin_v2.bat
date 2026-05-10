@echo off
setlocal EnableExtensions

net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Solicitando permisos de administrador...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set BASE=C:\GNS Software\GNS Personal PRO
set SRC=C:\Windows\SysWOW64\Redist\MS\System
set BKP=%BASE%\_Backup_OCX_Instalados
set LOG=%BASE%\instalar_ocx_encontrados_vb6_admin_v2_log.txt

echo ============================================================
echo INSTALAR OCX ENCONTRADOS - ADMIN V2
echo ============================================================
echo.
echo Esta ventana ya esta elevada como administrador.
echo.
pause

if not exist "%BASE%" (
  echo ERROR: No existe carpeta base: %BASE%
  pause
  exit /b 1
)

if not exist "%SRC%" (
  echo ERROR: No existe carpeta origen: %SRC%
  pause
  exit /b 1
)

if not exist "%BKP%" mkdir "%BKP%"

echo INSTALAR OCX ENCONTRADOS ADMIN V2 %DATE% %TIME% > "%LOG%"
echo Origen=%SRC% >> "%LOG%"
echo Destino=%BASE% >> "%LOG%"
echo. >> "%LOG%"

for %%F in (msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx) do (
  echo Procesando %%F...
  echo Procesando %%F... >> "%LOG%"
  if exist "%BASE%\%%F" copy "%BASE%\%%F" "%BKP%\%%F.bak" /Y >> "%LOG%" 2>&1
  if exist "%SRC%\%%F" (
    copy "%SRC%\%%F" "%BASE%\%%F" /Y >> "%LOG%" 2>&1
    echo Copiado %%F >> "%LOG%"
  ) else (
    echo FALTA origen: %SRC%\%%F >> "%LOG%"
    echo FALTA origen: %SRC%\%%F
  )
)

echo. >> "%LOG%"
echo Registrando con SysWOW64 regsvr32... >> "%LOG%"
echo.
echo Registrando con SysWOW64 regsvr32...

for %%F in (msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx) do (
  if exist "%BASE%\%%F" (
    echo Registrando %%F...
    echo Registrando %%F... >> "%LOG%"
    C:\Windows\SysWOW64\regsvr32.exe /s "%BASE%\%%F"
    echo Resultado regsvr32 %%F: %errorlevel% >> "%LOG%"
  ) else (
    echo No existe para registrar: %%F >> "%LOG%"
  )
)

echo. >> "%LOG%"
echo Verificacion final: >> "%LOG%"
for %%F in (msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx) do (
  if exist "%BASE%\%%F" (
    echo OK LOCAL: %%F >> "%LOG%"
  ) else (
    echo FALTA LOCAL: %%F >> "%LOG%"
  )
)

echo.
echo Finalizado.
echo Log:
echo %LOG%
echo.
echo Ahora ejecute auditar_dependencias_ocx_sistema_gestion.vbs para confirmar presencia local.
echo Si un modulo falla, ejecute regsvr32 visible para ver el mensaje exacto.
echo.
pause
