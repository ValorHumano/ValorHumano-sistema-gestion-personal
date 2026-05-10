@echo off
setlocal EnableExtensions

net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Solicitando permisos de administrador...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set BASE=C:\GNS Software\GNS Personal PRO
set EMP=%BASE%\Valor Humano
set LOG=%BASE%\reparacion_error0_respaldos_y_modulos_log.txt
set REGKEY=HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal

echo ============================================================
echo REPARAR ERROR 0 - RESPALDOS Y MODULOS
echo ============================================================
echo.
echo Cierre Sistema de Gestion antes de continuar.
echo Este script NO toca licencia, usuarios ni datos de liquidacion.
echo Crea carpetas necesarias, corrige rutas, permisos basicos
echo y registra componentes locales OCX/DLL.
echo.
pause

echo REPARACION ERROR 0 %DATE% %TIME% > "%LOG%"
echo BASE=%BASE% >> "%LOG%"
echo EMP=%EMP% >> "%LOG%"
echo. >> "%LOG%"

if not exist "%BASE%" (
  echo ERROR: No existe carpeta base: %BASE%
  echo ERROR: No existe carpeta base >> "%LOG%"
  pause
  exit /b 1
)

if not exist "%EMP%" (
  echo ERROR: No existe carpeta empresa: %EMP%
  echo ERROR: No existe carpeta empresa >> "%LOG%"
  pause
  exit /b 1
)

echo 1. Creando carpetas necesarias...
echo 1. Creando carpetas necesarias... >> "%LOG%"
for %%D in ("%EMP%\Respaldos" "%EMP%\HistorialLaboral" "%EMP%\imgEmpleados" "%EMP%\MTSS" "%EMP%\Reportes" "C:\GnsTmp" "C:\MTSS - GNS" "C:\BPS - GNS" "C:\FOCER - GNS") do (
  if not exist "%%~D" (
    mkdir "%%~D" >> "%LOG%" 2>&1
    echo CREADA: %%~D >> "%LOG%"
  ) else (
    echo OK: %%~D >> "%LOG%"
  )
)

echo 2. Quitando atributo solo lectura en archivos clave...
echo 2. Quitando atributo solo lectura... >> "%LOG%"
attrib -r "%BASE%\Usuarios.mdb" >> "%LOG%" 2>&1
attrib -r "%EMP%\Personal.mdb" >> "%LOG%" 2>&1
attrib -r "%BASE%\ListEmpresas.ini" >> "%LOG%" 2>&1
attrib -r "%BASE%\ListEmpresas" >> "%LOG%" 2>&1
attrib -r "%EMP%\*.*" /s >> "%LOG%" 2>&1

echo 3. Probando permisos de escritura...
echo 3. Probando permisos de escritura... >> "%LOG%"
echo test > "%EMP%\Respaldos\_test_escritura.tmp" 2>> "%LOG%"
if exist "%EMP%\Respaldos\_test_escritura.tmp" (
  del "%EMP%\Respaldos\_test_escritura.tmp" >> "%LOG%" 2>&1
  echo OK escritura en Respaldos >> "%LOG%"
) else (
  echo ERROR escritura en Respaldos >> "%LOG%"
)

echo test > "C:\GnsTmp\_test_escritura.tmp" 2>> "%LOG%"
if exist "C:\GnsTmp\_test_escritura.tmp" (
  del "C:\GnsTmp\_test_escritura.tmp" >> "%LOG%" 2>&1
  echo OK escritura en C:\GnsTmp >> "%LOG%"
) else (
  echo ERROR escritura en C:\GnsTmp >> "%LOG%"
)

echo 4. Corrigiendo rutas de registro...
echo 4. Corrigiendo rutas de registro... >> "%LOG%"
reg add "%REGKEY%" /v PathAplicacion /t REG_SZ /d "%BASE%\\" /f >> "%LOG%" 2>&1
reg add "%REGKEY%" /v BaseGral /t REG_SZ /d "%BASE%\\" /f >> "%LOG%" 2>&1
reg add "%REGKEY%" /v BaseGralLstEmp /t REG_SZ /d "%BASE%\\" /f >> "%LOG%" 2>&1

echo 5. Corrigiendo ListEmpresas...
echo 5. Corrigiendo ListEmpresas... >> "%LOG%"
echo %EMP% ^< -^> Sistema de Gestion> "%BASE%\ListEmpresas"
echo %EMP% ^< -^> Sistema de Gestion> "%BASE%\ListEmpresas.ini"
powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-Content -LiteralPath '%BASE%\ListEmpresas') -replace '< - >','<->' | Set-Content -LiteralPath '%BASE%\ListEmpresas' -Encoding ASCII; (Get-Content -LiteralPath '%BASE%\ListEmpresas.ini') -replace '< - >','<->' | Set-Content -LiteralPath '%BASE%\ListEmpresas.ini' -Encoding ASCII" >> "%LOG%" 2>&1

echo 6. Registrando OCX/DLL locales...
echo 6. Registrando OCX/DLL locales... >> "%LOG%"
for %%F in ("%BASE%\*.ocx" "%BASE%\*.dll") do (
  if exist "%%~fF" (
    echo Registrando %%~nxF >> "%LOG%"
    C:\Windows\SysWOW64\regsvr32.exe /s "%%~fF" >> "%LOG%" 2>&1
  )
)

echo 7. Verificando componentes de respaldo/zip...
echo 7. Verificando componentes de respaldo/zip... >> "%LOG%"
if exist "%BASE%\XceedZip.dll" (
  echo OK XceedZip.dll local >> "%LOG%"
  C:\Windows\SysWOW64\regsvr32.exe /s "%BASE%\XceedZip.dll" >> "%LOG%" 2>&1
) else (
  echo AVISO: No se encontro XceedZip.dll local. Si respaldo comprimido falla, puede ser por este componente. >> "%LOG%"
)

echo 8. Listado final carpetas clave...
echo 8. Listado final carpetas clave... >> "%LOG%"
dir "%EMP%" >> "%LOG%" 2>&1
dir "%EMP%\Respaldos" >> "%LOG%" 2>&1

echo.
echo Reparacion terminada.
echo Log:
echo %LOG%
echo.
echo Abra el sistema y pruebe de nuevo el modulo que daba Error 0.
echo Si vuelve a fallar, pegue el log y la pantalla exacta.
echo.
pause
