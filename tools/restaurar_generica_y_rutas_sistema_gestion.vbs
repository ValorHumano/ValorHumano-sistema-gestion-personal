' Restaura la carpeta Generica y repara rutas basicas.
' Motivo: el sistema viejo necesita la empresa generica UY para iniciar.
' No modifica la base Valor Humano salvo que reescribe ListEmpresas con una sola entrada visible.

Option Explicit

Dim fso, shell, basePath, ocultasPath, outPath, outFile, stamp
Dim srcGenerica, dstGenerica, listLine

basePath = "C:\GNS Software\GNS Personal PRO"
ocultasPath = basePath & "\_Empresas_Ocultas"
stamp = Timestamp()
outPath = basePath & "\restaurar_generica_y_rutas_" & stamp & ".txt"
listLine = "C:\GNS Software\GNS Personal PRO\Valor Humano <-> Sistema de Gestion"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "RESTAURAR GENERICA Y RUTAS - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")

If Not fso.FolderExists(basePath) Then
    outFile.WriteLine "ERROR: No existe carpeta base: " & basePath
    outFile.Close
    WScript.Echo "ERROR: No existe carpeta base. Ver: " & outPath
    WScript.Quit 1
End If

outFile.WriteLine "1) RESTAURAR CARPETA GENERICA"
outFile.WriteLine String(90, "-")
dstGenerica = basePath & "\Generica"

If fso.FolderExists(dstGenerica) Then
    outFile.WriteLine "OK: Generica ya existe en raiz: " & dstGenerica
Else
    srcGenerica = FindFirstFolderStartingWith(ocultasPath, "Generica_")
    If srcGenerica = "" Then
        outFile.WriteLine "ERROR: No se encontro carpeta Generica_ dentro de " & ocultasPath
        outFile.WriteLine "Debe restaurarse manualmente la carpeta Generica original."
    Else
        On Error Resume Next
        fso.MoveFolder srcGenerica, dstGenerica
        If Err.Number <> 0 Then
            outFile.WriteLine "ERROR moviendo Generica: " & Err.Description
            Err.Clear
        Else
            outFile.WriteLine "OK: Generica restaurada: " & srcGenerica & " -> " & dstGenerica
        End If
        On Error GoTo 0
    End If
End If
outFile.WriteLine ""

outFile.WriteLine "2) REPARAR LISTEMPRESAS"
outFile.WriteLine String(90, "-")
WriteTextFile basePath & "\ListEmpresas.ini", listLine
WriteTextFile basePath & "\ListEmpresas", listLine
outFile.WriteLine "ListEmpresas.ini y ListEmpresas escritos con: " & listLine
outFile.WriteLine ""

outFile.WriteLine "3) REPARAR REGISTRO DE RUTAS"
outFile.WriteLine String(90, "-")
RegWrite "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\PathAplicacion", basePath & "\"
RegWrite "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGral", basePath & "\"
RegWrite "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGralLstEmp", basePath & "\"
RegWrite "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\PathAplicacion", basePath & "\"
RegWrite "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGral", basePath & "\"
RegWrite "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGralLstEmp", basePath & "\"
outFile.WriteLine ""

outFile.WriteLine "4) RESULTADO"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Generica debe existir en raiz porque el sistema la usa como plantilla/pais UY."
outFile.WriteLine "No deberia usarse como empresa operativa. La empresa visible en ListEmpresas queda como Sistema de Gestion."
outFile.WriteLine "Abra SistemaGestion.exe y pruebe nuevamente."
outFile.WriteLine ""
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Proceso terminado. Ver reporte: " & outPath

Function FindFirstFolderStartingWith(parentPath, prefix)
    Dim folder, subfolder
    FindFirstFolderStartingWith = ""
    If Not fso.FolderExists(parentPath) Then Exit Function
    Set folder = fso.GetFolder(parentPath)
    For Each subfolder In folder.SubFolders
        If LCase(Left(subfolder.Name, Len(prefix))) = LCase(prefix) Then
            FindFirstFolderStartingWith = subfolder.Path
            Exit Function
        End If
    Next
End Function

Sub WriteTextFile(path, text)
    Dim ts
    Set ts = fso.CreateTextFile(path, True)
    ts.WriteLine text
    ts.Close
End Sub

Sub RegWrite(path, value)
    On Error Resume Next
    shell.RegWrite path, value, "REG_SZ"
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR registro: " & path & " -> " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "OK registro: " & path & " = " & value
    End If
    On Error GoTo 0
End Sub

Function Timestamp()
    Timestamp = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & "_" & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
End Function
