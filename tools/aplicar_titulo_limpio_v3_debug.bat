@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\SistemaGestion.exe
set PS1=%BASE%\monitor_titulo_sistema_gestion_v3.ps1
set VBS=%BASE%\abrir_sistema_gestion_titulo_limpio_v3.vbs
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk
set LOG=%BASE%\aplicar_titulo_limpio_v3_debug_log.txt

echo ============================================================
echo APLICAR TITULO LIMPIO V3 DEBUG - SISTEMA DE GESTION
echo ============================================================
echo.
echo Este archivo NO modifica EXE, MDB, DLL ni OCX.
echo Si ocurre error, quedara guardado en:
echo %LOG%
echo.
pause

echo INICIO %DATE% %TIME% > "%LOG%"
echo BASE=%BASE% >> "%LOG%"
echo EXE=%EXE% >> "%LOG%"
echo PS1=%PS1% >> "%LOG%"
echo VBS=%VBS% >> "%LOG%"
echo SHORTCUT=%SHORTCUT% >> "%LOG%"
echo. >> "%LOG%"

if not exist "%BASE%" (
  echo ERROR: No existe carpeta base: %BASE%
  echo ERROR: No existe carpeta base: %BASE% >> "%LOG%"
  pause
  exit /b 1
)

if not exist "%EXE%" (
  echo ERROR: No existe SistemaGestion.exe
  echo ERROR: No existe SistemaGestion.exe >> "%LOG%"
  pause
  exit /b 1
)

echo Creando monitor PowerShell...
echo Creando monitor PowerShell... >> "%LOG%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ps1='C:\GNS Software\GNS Personal PRO\monitor_titulo_sistema_gestion_v3.ps1'; $txt=@'
$ErrorActionPreference = 'SilentlyContinue'
$TargetTitle = 'Sistema de Gestion'
Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WinApiTitleV3 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern bool SetWindowText(IntPtr hWnd, string lpString);
}
"@
$end = (Get-Date).AddHours(12)
while ((Get-Date) -lt $end) {
    $callback = [WinApiTitleV3+EnumWindowsProc]{
        param([IntPtr]$hWnd, [IntPtr]$lParam)
        if ([WinApiTitleV3]::IsWindowVisible($hWnd)) {
            $sb = New-Object System.Text.StringBuilder 512
            [void][WinApiTitleV3]::GetWindowText($hWnd, $sb, $sb.Capacity)
            $title = $sb.ToString()
            if ($title -like '*GNS Personal*' -or $title -like '*Version Evaluacion*' -or $title -like '*Versión Evaluación*') {
                [void][WinApiTitleV3]::SetWindowText($hWnd, $TargetTitle)
            }
        }
        return $true
    }
    [void][WinApiTitleV3]::EnumWindows($callback, [IntPtr]::Zero)
    Start-Sleep -Milliseconds 250
}
'@; Set-Content -LiteralPath $ps1 -Value $txt -Encoding UTF8" 1>> "%LOG%" 2>> "%LOG%"

echo Creando lanzador VBS...
echo Creando lanzador VBS... >> "%LOG%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$vbs='C:\GNS Software\GNS Personal PRO\abrir_sistema_gestion_titulo_limpio_v3.vbs'; $txt=@'
Option Explicit
Dim shell, basePath, exePath, ps1, cmd
basePath = "C:\GNS Software\GNS Personal PRO"
exePath = basePath & "\SistemaGestion.exe"
ps1 = basePath & "\monitor_titulo_sistema_gestion_v3.ps1"
Set shell = CreateObject("WScript.Shell")
shell.Run """" & exePath & """", 1, False
WScript.Sleep 1500
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """"
shell.Run cmd, 0, False
'@; Set-Content -LiteralPath $vbs -Value $txt -Encoding ASCII" 1>> "%LOG%" 2>> "%LOG%"

echo Recreando acceso directo...
echo Recreando acceso directo... >> "%LOG%"
if exist "%SHORTCUT%" del "%SHORTCUT%" 1>> "%LOG%" 2>> "%LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='wscript.exe'; $s.Arguments='""%VBS%""'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%EXE%,0'; $s.Save()" 1>> "%LOG%" 2>> "%LOG%"

echo.
echo FINALIZADO.
echo Revise el log:
echo %LOG%
echo.
echo Ahora cierre el sistema si esta abierto y abra desde el acceso del Escritorio:
echo Sistema de Gestion
echo.
echo FIN %DATE% %TIME% >> "%LOG%"
pause
