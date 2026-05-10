' Abre SistemaGestion.exe y aplica titulo visual limpio.
' No modifica EXE, MDB, DLL ni OCX.

Option Explicit
Dim shell, basePath, ps1, cmd

basePath = "C:\GNS Software\GNS Personal PRO"
ps1 = basePath & "\monitor_titulo_sistema_gestion.ps1"

Set shell = CreateObject("WScript.Shell")
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """"
shell.Run cmd, 0, False
