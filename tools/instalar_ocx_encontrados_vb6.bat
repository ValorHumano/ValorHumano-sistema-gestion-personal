@echo off
setlocal EnableExtensions

set BASE=C:\GNS Software\GNS Personal PRO
set SRC=C:\Windows\SysWOW64\Redist\MS\System
set BKP=%BASE%\_Backup_OCX_Instalados
set LOG=%BASE%\instalar_ocx_encontrados_vb6_log.txt

echo ============================================================
echo INSTALAR OCX ENCONTRADOS - SISTEMA DE GESTION
echo ============================================================
echo.
echo Ejecutar como Administrador.
echo.
echo Origen preferido:
echo %SRC%
echo.
echo Destino:
echo %BASE%
echo.
echo Archivos:
echo - msadodc.ocx
echo - comdlg32.ocx
echo - mscomct2.ocx
echo - msflxgrd.ocx
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

echo INSTALAR OCX ENCONTRADOS %DATE% %TIME% > "%LOG%"
echo Origen=%SRC% >> "%LOG%"
echo Destino=%BASE% >> "%LOG%"
echo. >> "%LOG%"

set MISSING=0
for %%F in (msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx) do (
  echo Procesando %%F...
  echo Procesando %%F... >> "%LOG%"

  if exist "%BASE%\%%F" (
    copy "%BASE%\%%F" "%BKP%\%%F.bak" /Y >> "%LOG%" 2>&1
  )

  if exist "%SRC%\%%F" (
    copy "%SRC%\%%F" "%BASE%\%%F" /Y >> "%LOG%" 2>&1
    if errorlevel 1 (
      echo ERROR copiando %%F >> "%LOG%"
      echo ERROR copiando %%F
      set MISSING=1
    ) else (
      echo OK copiado %%F >> "%LOG%"
    )
  ) else (
    echo FALTA origen: %SRC%\%%F >> "%LOG%"
    echo FALTA origen: %SRC%\%%F
    set MISSING=1
  )
)

echo. >> "%LOG%"
echo Registrando OCX con regsvr32... >> "%LOG%"
echo.
echo Registrando OCX con regsvr32...

for %%F in (msadodc.ocx comdlg32.ocx mscomct2.ocx msflxgrd.ocx) do (
  if exist "%BASE%\%%F" (
    echo Registrando %%F...
    echo Registrando %%F... >> "%LOG%"
    C:\Windows\SysWOW64\regsvr32.exe /s "%BASE%\%%F" >> "%LOG%" 2>&1
    if errorlevel 1 (
      echo AVISO: regsvr32 devolvio error en %%F >> "%LOG%"
      echo AVISO: regsvr32 devolvio error en %%F
    ) else (
      echo OK registrado %%F >> "%LOG%"
    )
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
if "%MISSING%"=="1" (
  echo Termino con avisos. Revise el log:
) else (
  echo Termino correctamente. Revise el log:
)
echo %LOG%
echo.
echo Luego ejecute auditar_dependencias_ocx_sistema_gestion.vbs para confirmar.
echo.
pause
