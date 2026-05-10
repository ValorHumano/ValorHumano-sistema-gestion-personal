$ErrorActionPreference = 'SilentlyContinue'

# Monitor visual seguro: no modifica EXE, MDB, DLL ni OCX.
# Cambia el titulo visible de la ventana mientras el sistema esta abierto.

$Base = 'C:\GNS Software\GNS Personal PRO'
$Exe = Join-Path $Base 'SistemaGestion.exe'
$TargetTitle = 'Sistema de Gestion'

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinTitle {
    [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    public static extern bool SetWindowText(IntPtr hWnd, string lpString);
}
"@

if (!(Test-Path $Exe)) {
    exit 1
}

# Si no esta abierto, lo abre.
$procs = Get-Process | Where-Object { $_.Path -eq $Exe }
if (!$procs) {
    Start-Process -FilePath $Exe -WorkingDirectory $Base | Out-Null
    Start-Sleep -Seconds 3
}

# Durante 8 horas, intenta mantener el titulo visual limpio.
$end = (Get-Date).AddHours(8)
while ((Get-Date) -lt $end) {
    $procs = Get-Process -Name 'SistemaGestion' -ErrorAction SilentlyContinue
    if (!$procs) {
        Start-Sleep -Seconds 2
        continue
    }

    foreach ($p in $procs) {
        $p.Refresh()
        if ($p.MainWindowHandle -ne 0) {
            [WinTitle]::SetWindowText($p.MainWindowHandle, $TargetTitle) | Out-Null
        }
    }
    Start-Sleep -Milliseconds 800
}
