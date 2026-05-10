@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\SistemaGestion.exe
set PS1=%BASE%\monitor_titulo_sistema_gestion_v2.ps1
set VBS=%BASE%\abrir_sistema_gestion_titulo_limpio_v2.vbs
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

echo ============================================================
echo APLICAR TITULO LIMPIO V2 - SISTEMA DE GESTION
echo ============================================================
echo.
echo Cierre el sistema antes de continuar.
echo Este proceso NO modifica EXE, MDB, DLL ni OCX.
echo Crea un lanzador que monitorea cualquier ventana con GNS,
echo Version Evaluacion o SistemaGestion y cambia el titulo visible.
echo.
pause

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

echo Creando monitor V2...
powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
$ErrorActionPreference = 'SilentlyContinue'
$Base = 'C:\GNS Software\GNS Personal PRO'
$Exe = Join-Path $Base 'SistemaGestion.exe'
$TargetTitle = 'Sistema de Gestion'

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WinApiTitle {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern bool SetWindowText(IntPtr hWnd, string lpString);
}
"@

if (!(Test-Path $Exe)) { exit 1 }

# Si el programa no esta abierto, lo abre.
$running = Get-Process -Name 'SistemaGestion' -ErrorAction SilentlyContinue
if (!$running) {
    Start-Process -FilePath $Exe -WorkingDirectory $Base | Out-Null
    Start-Sleep -Seconds 2
}

$end = (Get-Date).AddHours(12)
while ((Get-Date) -lt $end) {
    # 1) Por proceso
    $procs = Get-Process -Name 'SistemaGestion' -ErrorAction SilentlyContinue
    foreach ($p in $procs) {
        $p.Refresh()
        if ($p.MainWindowHandle -ne 0) {
            [WinApiTitle]::SetWindowText($p.MainWindowHandle, $TargetTitle) | Out-Null
        }
    }

    # 2) Por titulo de ventana, aunque el proceso cambie el titulo o el nombre no coincida.
    $callback = [WinApiTitle+EnumWindowsProc]{
        param([IntPtr]$hWnd, [IntPtr]$lParam)
        if ([WinApiTitle]::IsWindowVisible($hWnd)) {
            $sb = New-Object System.Text.StringBuilder 512
            [void][WinApiTitle]::GetWindowText($hWnd, $sb, $sb.Capacity)
            $title = $sb.ToString()
            if ($title -like '*GNS Personal*' -or $title -like '*Version Evaluacion*' -or $title -like '*Versión Evaluación*' -or $title -like '*SistemaGestion*') {
                [void][WinApiTitle]::SetWindowText($hWnd, $TargetTitle)
            }
        }
        return $true
    }
    [void][WinApiTitle]::EnumWindows($callback, [IntPtr]::Zero)

    Start-Sleep -Milliseconds 250
}
'@ | Set-Content -LiteralPath '%PS1%' -Encoding UTF8"

echo Creando lanzador VBS V2...
powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
Option Explicit
Dim shell, ps1, cmd
ps1 = ""C:\GNS Software\GNS Personal PRO\monitor_titulo_sistema_gestion_v2.ps1""
Set shell = CreateObject(""WScript.Shell"")
cmd = ""powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """""" & ps1 & """"""""
shell.Run cmd, 0, False
'@ | Set-Content -LiteralPath '%VBS%' -Encoding ASCII"

echo Recreando acceso directo del escritorio...
if exist "%SHORTCUT%" del "%SHORTCUT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='wscript.exe'; $s.Arguments='""%VBS%""'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%EXE%,0'; $s.Save()"

echo.
echo Listo.
echo Cierre cualquier ventana abierta del sistema.
echo Luego abra desde el escritorio: Sistema de Gestion
echo.
pause
