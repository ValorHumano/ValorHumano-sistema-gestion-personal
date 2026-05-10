' Aplicador V5: crea acceso y monitor de titulo con deteccion automatica del ejecutable.
' No modifica EXE, MDB, DLL ni OCX.
' Corrige error: no se encuentra el archivo especificado.

Option Explicit

Dim fso, shell, basePath, exePath, ps1Path, launcherPath, shortcutPath, logPath
Dim ps, vbs, sc, log

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

basePath = "C:\GNS Software\GNS Personal PRO"
exePath = BuscarEjecutable(basePath)
ps1Path = basePath & "\monitor_titulo_sistema_gestion_v5.ps1"
launcherPath = basePath & "\abrir_sistema_gestion_titulo_limpio_v5.vbs"
shortcutPath = shell.SpecialFolders("Desktop") & "\Sistema de Gestion.lnk"
logPath = basePath & "\aplicar_titulo_limpio_v5_log.txt"

If Not fso.FolderExists(basePath) Then
    MsgBox "ERROR: No existe la carpeta base:" & vbCrLf & basePath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If

If exePath = "" Then
    MsgBox "ERROR: No encuentro el ejecutable del sistema." & vbCrLf & vbCrLf & _
           "Busque en la carpeta:" & vbCrLf & basePath & vbCrLf & vbCrLf & _
           "Debe existir SistemaGestion.exe o SistemaGestion.", 16, "Sistema de Gestion"
    WScript.Quit 1
End If

' Crear monitor PowerShell.
Set ps = fso.CreateTextFile(ps1Path, True)
ps.WriteLine "$ErrorActionPreference = 'SilentlyContinue'"
ps.WriteLine "$TargetTitle = 'Sistema de Gestion'"
ps.WriteLine "Add-Type @'"
ps.WriteLine "using System;"
ps.WriteLine "using System.Text;"
ps.WriteLine "using System.Runtime.InteropServices;"
ps.WriteLine "public class WinApiTitleV5 {"
ps.WriteLine "    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);"
ps.WriteLine "    [DllImport(""user32.dll"")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);"
ps.WriteLine "    [DllImport(""user32.dll"")] public static extern bool IsWindowVisible(IntPtr hWnd);"
ps.WriteLine "    [DllImport(""user32.dll"", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);"
ps.WriteLine "    [DllImport(""user32.dll"", CharSet=CharSet.Auto)] public static extern bool SetWindowText(IntPtr hWnd, string lpString);"
ps.WriteLine "}"
ps.WriteLine "'@"
ps.WriteLine "$end = (Get-Date).AddHours(12)"
ps.WriteLine "while ((Get-Date) -lt $end) {"
ps.WriteLine "    $callback = [WinApiTitleV5+EnumWindowsProc]{"
ps.WriteLine "        param([IntPtr]$hWnd, [IntPtr]$lParam)"
ps.WriteLine "        if ([WinApiTitleV5]::IsWindowVisible($hWnd)) {"
ps.WriteLine "            $sb = New-Object System.Text.StringBuilder 512"
ps.WriteLine "            [void][WinApiTitleV5]::GetWindowText($hWnd, $sb, $sb.Capacity)"
ps.WriteLine "            $title = $sb.ToString()"
ps.WriteLine "            if ($title -like '*GNS Personal*' -or $title -like '*Version Evaluacion*' -or $title -like '*Versión Evaluación*' -or $title -like '*4.1 Mejora 90*') {"
ps.WriteLine "                [void][WinApiTitleV5]::SetWindowText($hWnd, $TargetTitle)"
ps.WriteLine "            }"
ps.WriteLine "        }"
ps.WriteLine "        return $true"
ps.WriteLine "    }"
ps.WriteLine "    [void][WinApiTitleV5]::EnumWindows($callback, [IntPtr]::Zero)"
ps.WriteLine "    Start-Sleep -Milliseconds 300"
ps.WriteLine "}"
ps.Close

' Crear lanzador VBS con ruta real detectada.
Set vbs = fso.CreateTextFile(launcherPath, True)
vbs.WriteLine "Option Explicit"
vbs.WriteLine "Dim shell, exePath, ps1Path, cmd, fso"
vbs.WriteLine "Set fso = CreateObject(""Scripting.FileSystemObject"")"
vbs.WriteLine "Set shell = CreateObject(""WScript.Shell"")"
vbs.WriteLine "exePath = """ & EscapeVbs(exePath) & """"
vbs.WriteLine "ps1Path = """ & EscapeVbs(ps1Path) & """"
vbs.WriteLine "If Not fso.FileExists(exePath) Then MsgBox ""No se encuentra el ejecutable: "" & exePath, 16, ""Sistema de Gestion"": WScript.Quit 1"
vbs.WriteLine "shell.Run Chr(34) & exePath & Chr(34), 1, False"
vbs.WriteLine "WScript.Sleep 1500"
vbs.WriteLine "cmd = ""powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "" & Chr(34) & ps1Path & Chr(34)"
vbs.WriteLine "shell.Run cmd, 0, False"
vbs.Close

' Crear acceso directo.
If fso.FileExists(shortcutPath) Then
    On Error Resume Next
    fso.DeleteFile shortcutPath, True
    On Error GoTo 0
End If

Set sc = shell.CreateShortcut(shortcutPath)
sc.TargetPath = "wscript.exe"
sc.Arguments = Chr(34) & launcherPath & Chr(34)
sc.WorkingDirectory = basePath
sc.WindowStyle = 1
sc.Description = "Sistema de Gestion"
sc.IconLocation = exePath & ",0"
sc.Save

Set log = fso.CreateTextFile(logPath, True)
log.WriteLine "Aplicador V5 ejecutado correctamente: " & Now
log.WriteLine "Ejecutable detectado: " & exePath
log.WriteLine "PS1: " & ps1Path
log.WriteLine "Launcher: " & launcherPath
log.WriteLine "Acceso: " & shortcutPath
log.Close

MsgBox "Listo." & vbCrLf & vbCrLf & _
       "Ejecutable detectado:" & vbCrLf & exePath & vbCrLf & vbCrLf & _
       "Abra desde el acceso del Escritorio: Sistema de Gestion", 64, "Sistema de Gestion"

Function BuscarEjecutable(pathBase)
    Dim p
    BuscarEjecutable = ""
    p = pathBase & "\SistemaGestion.exe"
    If fso.FileExists(p) Then BuscarEjecutable = p: Exit Function
    p = pathBase & "\SistemaGestion"
    If fso.FileExists(p) Then BuscarEjecutable = p: Exit Function
    p = pathBase & "\GnsPersonal.exe"
    If fso.FileExists(p) Then BuscarEjecutable = p: Exit Function
    p = pathBase & "\GNS Personal PRO.exe"
    If fso.FileExists(p) Then BuscarEjecutable = p: Exit Function
End Function

Function EscapeVbs(s)
    EscapeVbs = Replace(s, """", """")
End Function
