' Buscador simple de textos dentro de SistemaGestion.exe.
' No modifica nada. Evita problemas de PowerShell.

Option Explicit

Dim fso, basePath, exePath, outPath, outFile, content, terms, i, term, pos

basePath = "C:\GNS Software\GNS Personal PRO"
exePath = basePath & "\SistemaGestion.exe"
outPath = basePath & "\busqueda_textos_marca_en_exe.txt"
terms = Array("GNS", "GNS Personal", "GnsPersonal", "Personal", "Evaluacion", "Evaluación", "Version", "Versión", "Mejora", "4.1", "4.1 Mejora 90", "SistemaGestion", "Sistema de Gestion")

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "BUSQUEDA VBS DE TEXTOS EN SistemaGestion.exe"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Exe: " & exePath
outFile.WriteLine String(90, "-")

If Not fso.FileExists(exePath) Then
    outFile.WriteLine "ERROR: No existe " & exePath
    outFile.Close
    WScript.Echo "ERROR: No existe SistemaGestion.exe. Ver: " & outPath
    WScript.Quit 1
End If

On Error Resume Next
content = ReadBinaryAsText(exePath)
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR leyendo exe: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR leyendo exe. Ver: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

outFile.WriteLine "Caracteres leidos: " & Len(content)
outFile.WriteLine ""

For i = 0 To UBound(terms)
    term = CStr(terms(i))
    pos = InStr(1, content, term, vbTextCompare)
    outFile.WriteLine "TERMINO: " & term
    If pos > 0 Then
        outFile.WriteLine "ENCONTRADO: SI | posicion aprox: " & pos
        outFile.WriteLine "CONTEXTO: " & CleanSnippet(Mid(content, MaxInt(1, pos - 80), 260))
    Else
        outFile.WriteLine "ENCONTRADO: NO"
    End If
    outFile.WriteLine ""
Next

outFile.WriteLine String(90, "-")
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Reporte generado en: " & outPath

Function ReadBinaryAsText(path)
    Dim stream, bytes, j, s
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.LoadFromFile path
    bytes = stream.Read
    stream.Close
    s = ""
    For j = 1 To LenB(bytes)
        s = s & Chr(AscB(MidB(bytes, j, 1)))
    Next
    ReadBinaryAsText = s
End Function

Function CleanSnippet(s)
    Dim k, ch, out
    out = ""
    For k = 1 To Len(s)
        ch = Mid(s, k, 1)
        If Asc(ch) >= 32 And Asc(ch) <= 126 Then
            out = out & ch
        Else
            out = out & "."
        End If
    Next
    CleanSnippet = out
End Function

Function MaxInt(a, b)
    If a > b Then
        MaxInt = a
    Else
        MaxInt = b
    End If
End Function
