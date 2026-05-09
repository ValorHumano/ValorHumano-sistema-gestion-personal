@echo off
setlocal

echo ============================================================
echo REFRESCAR CACHE DE ICONOS DE WINDOWS
echo ============================================================
echo.
echo Este proceso reinicia el Explorador de Windows y limpia cache de iconos.
echo No borra el programa ni modifica bases de datos.
echo.
pause

echo Cerrando Explorador de Windows...
taskkill /f /im explorer.exe >nul 2>&1

echo Limpiando cache de iconos...
cd /d "%localappdata%"
attrib -h IconCache.db >nul 2>&1
del IconCache.db /a >nul 2>&1

cd /d "%localappdata%\Microsoft\Windows\Explorer" 2>nul
del iconcache*.db /a >nul 2>&1
del thumbcache*.db /a >nul 2>&1

echo Reiniciando Explorador de Windows...
start explorer.exe

echo.
echo Listo. Si el icono sigue igual, entonces el icono no quedo reemplazado dentro de SistemaGestion.exe.
echo En ese caso hay que volver a Resource Hacker ^> Icon Group ^> Replace Icon ^> Save.
echo.
pause
