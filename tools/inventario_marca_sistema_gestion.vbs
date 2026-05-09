' Inventario de marca GNS/Zinco/Sistema para rebranding seguro.
' No modifica nada.

Option Explicit

Dim fso, basePath, outPath, outFile
Dim terms

basePath = "C:\GNS Software\GNS Personal PRO"
outPath = basePath & "\inventario_marca_sistema_gestion.txt"
terms = Array("GNS", "Gns", "gns", "Zinco", "Personal PRO", "GNS Personal", "El Refugio", "Demo")

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "INVENTARIO DE MARCA - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Carpeta: " & basePath
outFile.WriteLine String(90, "-")

outFile.WriteLine "ARCHIVOS DE IMAGEN Y POSIBLES LOGOS"
outFile.WriteLine String(90, "-")
ListFilesByExt basePath, outFile, Array("bmp", "jpg", "jpeg", "png", "ico", "gif")

outFile.WriteLine ""
outFile.WriteLine "ARCHIVOS DE CONFIGURACION/TEXTO CON TERMINOS DE MARCA"
outFile.WriteLine String(90, "-")
SearchTextFiles basePath, outFile, terms

outFile.WriteLine ""
outFile.WriteLine "ARCHIVOS BINARIOS DONDE PODRIA ESTAR EMBEBIDA LA MARCA (NO MODIFICAR DIRECTO)"
outFile.WriteLine String(90, "-")
ListFilesByExt basePath, outFile, Array("exe", "dll", "ocx", "frx")

outFile.WriteLine ""
outFile.WriteLine String(90, "-")
outFile.WriteLine "FIN DEL INVENTARIO"
outFile.Close

WScript.Echo "Inventario generado en: " & outPath

Sub ListFilesByExt(folderPath, outFileObj, extArray)
    Dim folder, file, subfolder, ext, i
    If Not fso.FolderExists(folderPath) Then Exit Sub
    Set folder = fso.GetFolder(folderPath)
    For Each file In folder.Files
        ext = LCase(fso.GetExtensionName(file.Name))
        For i = 0 To UBound(extArray)
            If ext = LCase(extArray(i)) Then
                outFileObj.WriteLine file.Path & " | bytes=" & file.Size
            End If
        Next
    Next
    For Each subfolder In folder.SubFolders
        ListFilesByExt subfolder.Path, outFileObj, extArray
    Next
End Sub

Sub SearchTextFiles(folderPath, outFileObj, termsArray)
    Dim folder, file, subfolder, ext
    If Not fso.FolderExists(folderPath) Then Exit Sub
    Set folder = fso.GetFolder(folderPath)
    For Each file In folder.Files
        ext = LCase(fso.GetExtensionName(file.Name))
        If ext = "ini" Or ext = "txt" Or ext = "cfg" Or ext = "url" Or ext = "dat" Then
            SearchOneTextFile file.Path, outFileObj, termsArray
        End If
    Next
    For Each subfolder In folder.SubFolders
        SearchTextFiles subfolder.Path, outFileObj, termsArray
    Next
End Sub

Sub SearchOneTextFile(filePath, outFileObj, termsArray)
    Dim ts, line, n, i
    On Error Resume Next
    Set ts = fso.OpenTextFile(filePath, 1, False)
    If Err.Number <> 0 Then
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If
    On Error GoTo 0
    n = 0
    Do Until ts.AtEndOfStream
        line = ts.ReadLine
        n = n + 1
        For i = 0 To UBound(termsArray)
            If InStr(1, line, CStr(termsArray(i)), 1) > 0 Then
                outFileObj.WriteLine filePath & " | linea=" & n & " | " & Left(line, 220)
                Exit For
            End If
        Next
    Loop
    ts.Close
End Sub
