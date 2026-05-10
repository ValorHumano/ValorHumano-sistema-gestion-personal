@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO
set EXE=%BASE%\SistemaGestion.exe
set PS1=%BASE%\monitor_titulo_sistema_gestion.ps1
set VBS=%BASE%\abrir_sistema_gestion_titulo_limpio.vbs
set SHORTCUT=%USERPROFILE%\Desktop\Sistema de Gestion.lnk

echo ============================================================
echo APLICAR TITULO LIMPIO Y ACCESO - SISTEMA DE GESTION
echo ============================================================
echo.
echo Este proceso NO modifica el EXE, MDB, DLL ni OCX.
echo Crea un lanzador que abre el sistema y cambia visualmente
echo el titulo de ventana a: Sistema de Gestion.
echo.

if not exist "%EXE%" (
  echo ERROR: No existe "%EXE%"
  pause
  exit /b 1
)

echo Creando monitor de titulo...
powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
`$ErrorActionPreference = 'SilentlyContinue'
`$Base = 'C:\GNS Software\GNS Personal PRO'
`$Exe = Join-Path `$Base 'SistemaGestion.exe'
`$TargetTitle = 'Sistema de Gestion'

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinTitle {
    [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    public static extern bool SetWindowText(IntPtr hWnd, string lpString);
}
"@

if (!(Test-Path `$Exe)) { exit 1 }

`$procs = Get-Process | Where-Object { `$_.Path -eq `$Exe }
if (!`$procs) {
    Start-Process -FilePath `$Exe -WorkingDirectory `$Base | Out-Null
    Start-Sleep -Seconds 3
}

`$end = (Get-Date).AddHours(8)
while ((Get-Date) -lt `$end) {
    `$procs = Get-Process -Name 'SistemaGestion' -ErrorAction SilentlyContinue
    foreach (`$p in `$procs) {
        `$p.Refresh()
        if (`$p.MainWindowHandle -ne 0) {
            [WinTitle]::SetWindowText(`$p.MainWindowHandle, `$TargetTitle) | Out-Null
        }
    }
    Start-Sleep -Milliseconds 800
}
'@ | Set-Content -LiteralPath '%PS1%' -Encoding UTF8"

echo Creando lanzador VBS...
powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
Option Explicit
Dim shell, ps1, cmd
ps1 = ""C:\GNS Software\GNS Personal PRO\monitor_titulo_sistema_gestion.ps1""
Set shell = CreateObject(""WScript.Shell"")
cmd = ""powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """""" & ps1 & """"""""
shell.Run cmd, 0, False
'@ | Set-Content -LiteralPath '%VBS%' -Encoding ASCII"

echo Recreando acceso directo del escritorio...
if exist "%SHORTCUT%" del "%SHORTCUT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='wscript.exe'; $s.Arguments='""%VBS%""'; $s.WorkingDirectory='%BASE%'; $s.WindowStyle=1; $s.Description='Sistema de Gestion'; $s.IconLocation='%EXE%,0'; $s.Save()"

echo.
echo Listo.
echo Ahora abra el sistema desde el acceso del escritorio:
echo Sistema de Gestion
echo.
echo Si el icono sigue viendose viejo, reinicie Windows o el Explorador.
echo.
pause
