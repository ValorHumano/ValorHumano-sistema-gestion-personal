@echo off
setlocal
set OUT=C:\GNS Software\GNS Personal PRO\diagnostico_ejecutable_real_abierto.txt

echo DIAGNOSTICO EJECUTABLE REAL ABIERTO > "%OUT%"
echo Fecha: %DATE% %TIME% >> "%OUT%"
echo. >> "%OUT%"

echo === PROCESOS RELACIONADOS === >> "%OUT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Process | Where-Object { $_.ProcessName -like '*Gns*' -or $_.ProcessName -like '*Sistema*' -or $_.MainWindowTitle -like '*GNS*' -or $_.MainWindowTitle -like '*Sistema*' } | Select-Object ProcessName, Id, Path, MainWindowTitle | Format-List" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === ACCESO DIRECTO ESCRITORIO === >> "%OUT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Sistema de Gestion.lnk'; if(Test-Path $p){$s=(New-Object -ComObject WScript.Shell).CreateShortcut($p); 'Shortcut='+$p; 'TargetPath='+$s.TargetPath; 'Arguments='+$s.Arguments; 'WorkingDirectory='+$s.WorkingDirectory; 'IconLocation='+$s.IconLocation}else{'No existe acceso: '+$p}" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === ARCHIVOS EJECUTABLES EN CARPETA === >> "%OUT%"
dir "C:\GNS Software\GNS Personal PRO\*.exe" /b >> "%OUT%" 2>&1

echo Reporte generado:
echo %OUT%
echo.
pause
