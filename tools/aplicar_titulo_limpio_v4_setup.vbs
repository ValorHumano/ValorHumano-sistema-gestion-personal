' Aplicador V4: crea monitor de titulo limpio y acceso directo.
' No modifica EXE, MDB, DLL ni OCX.
' Evita BAT/PowerShell embebido problemático: este VBS escribe archivos linea por linea.

Option Explicit

Dim fso, shell, basePath, exePath, ps1Path, launcherPath, shortcutPath, logPath
Dim ps, vbs, sc

basePath = "C:\GNS Software\GNS Personal PRO"
exePath = basePath & "\SistemaGestion.exe"
ps1Path = basePath & "\monitor_titulo_sistema_gestion_v4.ps1"
launcherPath = basePath & "\abrir_sistema_gestion_titulo_limpio_v4.vbs"
shortcutPath = shellSpecialDesktop() & "\Sistema de Gestion.lnk"
logPath = basePath & "\aplicar_titulo_limpio_v4_log.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

If Not fso.FolderExists(basePath) Then
    MsgBox "ERROR: No existe la carpeta base: " & basePath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If

If Not fso.FileExists(exePath) Then
    MsgBox "ERROR: No existe SistemaGestion.exe en: " & exePath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If

Set ps = fso.CreateTextFile(ps1Path, True)
ps.WriteLine "$ErrorActionPreference = 'SilentlyContinue'"
ps.WriteLine "$TargetTitle = 'Sistema de Gestion'"
ps.WriteLine "Add-Type @'"
ps.WriteLine "using System;"
ps.WriteLine "using System.Text;"
ps.WriteLine "using System.Runtime.InteropServices;"
ps.WriteLine "public class WinApiTitleV4 {"
ps.WriteLine "    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);"
ps.WriteLine "    [DllImport(""user32.dll"")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);"
ps.WriteLine "    [DllImport(""user32.dll"")] public static extern bool IsWindowVisible(IntPtr hWnd);"
ps.WriteLine "    [DllImport(""user32.dll"", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);"
ps.WriteLine "    [DllImport(""user32.dll"", CharSet=CharSet.Auto)] public static extern bool SetWindowText(IntPtr hWnd, string lpString);"
ps.WriteLine "}"
ps.WriteLine "'@"
ps.WriteLine "$end = (Get-Date).AddHours(12)"
ps.WriteLine "while ((Get-Date) -lt $end) {"
ps.WriteLine "    $callback = [WinApiTitleV4+EnumWindowsProc]{"
ps.WriteLine "        param([IntPtr]$hWnd, [IntPtr]$lParam)"
ps.WriteLine "        if ([WinApiTitleV4]::IsWindowVisible($hWnd)) {"
ps.WriteLine "            $sb = New-Object System.Text.StringBuilder 512"
ps.WriteLine "            [void][WinApiTitleV4]::GetWindowText($hWnd, $sb, $sb.Capacity)"
ps.WriteLine "            $title = $sb.ToString()"
ps.WriteLine "            if ($title -like '*GNS Personal*' -or $title -like '*Version Evaluacion*' -or $title -like '*Versión Evaluación*' -or $title -like '*4.1 Mejora 90*') {"
ps.WriteLine "                [void][WinApiTitleV4]::SetWindowText($hWnd, $TargetTitle)"
ps.WriteLine "            }"
ps.WriteLine "        }"
ps.WriteLine "        return $true"
ps.WriteLine "    }"
ps.WriteLine "    [void][WinApiTitleV4]::EnumWindows($callback, [IntPtr]::Zero)"
ps.WriteLine "    Start-Sleep -Milliseconds 300"
ps.WriteLine "}"
ps.Close

Set vbs = fso.CreateTextFile(launcherPath, True)
vbs.WriteLine "Option Explicit"
vbs.WriteLine "Dim shell, basePath, exePath, ps1Path, cmd"
vbs.WriteLine "basePath = ""C:\GNS Software\GNS Personal PRO"""
vbs.WriteLine "exePath = basePath & ""\SistemaGestion.exe"""
vbs.WriteLine "ps1Path = basePath & ""\monitor_titulo_sistema_gestion_v4.ps1"""
vbs.WriteLine "Set shell = CreateObject(""WScript.Shell"")"
vbs.WriteLine "shell.Run """""" & exePath & """""", 1, False"
vbs.WriteLine "WScript.Sleep 1500"
vbs.WriteLine "cmd = ""powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """""" & ps1Path & """""""""
vbs.WriteLine "shell.Run cmd, 0, False"
vbs.Close

Set sc = shell.CreateShortcut(shortcutPath)
sc.TargetPath = "wscript.exe"
sc.Arguments = Chr(34) & launcherPath & Chr(34)
sc.WorkingDirectory = basePath
sc.WindowStyle = 1
sc.Description = "Sistema de Gestion"
sc.IconLocation = exePath & ",0"
sc.Save

Dim log
Set log = fso.CreateTextFile(logPath, True)
log.WriteLine "Aplicador V4 ejecutado correctamente: " & Now
log.WriteLine "PS1: " & ps1Path
log.WriteLine "Launcher: " & launcherPath
log.WriteLine "Acceso: " & shortcutPath
log.Close

MsgBox "Listo. Cierre el sistema si esta abierto y abra desde el acceso del Escritorio: Sistema de Gestion", 64, "Sistema de Gestion"

Function shellSpecialDesktop()
    Dim sh
    Set sh = CreateObject("WScript.Shell")
    shellSpecialDesktop = sh.SpecialFolders("Desktop")
End Function
