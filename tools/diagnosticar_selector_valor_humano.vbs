' Diagnostico del selector de empresas y permisos de Valor Humano.
' No modifica datos.

Option Explicit

Dim fso, basePath, empPath, outPath, outFile
Dim dao, dbU, dbP

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
outPath = basePath & "\diagnostico_selector_valor_humano.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "DIAGNOSTICO SELECTOR EMPRESA - VALOR HUMANO"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")

outFile.WriteLine "RUTAS"
outFile.WriteLine "BasePath existe: " & fso.FolderExists(basePath) & " -> " & basePath
outFile.WriteLine "Valor Humano existe: " & fso.FolderExists(empPath) & " -> " & empPath
outFile.WriteLine "Valor Humano Personal.mdb existe: " & fso.FileExists(empPath & "\Personal.mdb")
outFile.WriteLine "Usuarios.mdb existe: " & fso.FileExists(basePath & "\Usuarios.mdb")
outFile.WriteLine ""

outFile.WriteLine "CARPETAS DE LA RAIZ CON Personal.mdb"
ListCompanyFolders basePath, outFile
outFile.WriteLine ""

outFile.WriteLine "CONTENIDO ListEmpresas.ini"
DumpFile basePath & "\ListEmpresas.ini", outFile
outFile.WriteLine ""

outFile.WriteLine "CONTENIDO ListEmpresas"
DumpFile basePath & "\ListEmpresas", outFile
outFile.WriteLine ""

outFile.WriteLine "ARCHIVO CodEmp EN Valor Humano"
DumpFile empPath & "\CodEmp", outFile
outFile.WriteLine ""

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando DAO.DBEngine.120: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR DAO. Ver: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

If fso.FileExists(basePath & "\Usuarios.mdb") Then
    On Error Resume Next
    Set dbU = dao.OpenDatabase(basePath & "\Usuarios.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Usuarios.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "USUARIOS.MDB - Usuarios"
        DumpQuery dbU, "SELECT * FROM Usuarios", outFile
        outFile.WriteLine ""
        outFile.WriteLine "USUARIOS.MDB - EmpHabil"
        DumpQuery dbU, "SELECT * FROM EmpHabil", outFile
        outFile.WriteLine ""
        outFile.WriteLine "USUARIOS.MDB - EstEmp"
        DumpQuery dbU, "SELECT * FROM EstEmp", outFile
        dbU.Close
    End If
    On Error GoTo 0
End If

If fso.FileExists(empPath & "\Personal.mdb") Then
    On Error Resume Next
    Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine ""
        outFile.WriteLine "PERSONAL.MDB - Empresa"
        DumpQuery dbP, "SELECT * FROM Empresa", outFile
        outFile.WriteLine ""
        outFile.WriteLine "PERSONAL.MDB - Conteos clave"
        outFile.WriteLine "Personas=" & CountTable(dbP, "Personas")
        outFile.WriteLine "Contrato=" & CountTable(dbP, "Contrato")
        outFile.WriteLine "Conceptos=" & CountTable(dbP, "Conceptos")
        outFile.WriteLine "Valores=" & CountTable(dbP, "Valores")
        dbP.Close
    End If
    On Error GoTo 0
End If

outFile.WriteLine ""
outFile.WriteLine String(90, "-")
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Diagnostico generado en: " & outPath

Sub ListCompanyFolders(root, outFileObj)
    Dim folder, subfolder
    If Not fso.FolderExists(root) Then Exit Sub
    Set folder = fso.GetFolder(root)
    For Each subfolder In folder.SubFolders
        If fso.FileExists(subfolder.Path & "\Personal.mdb") Then
            outFileObj.WriteLine subfolder.Name & " -> " & subfolder.Path
        End If
    Next
End Sub

Sub DumpFile(path, outFileObj)
    Dim ts
    If Not fso.FileExists(path) Then
        outFileObj.WriteLine "NO EXISTE: " & path
        Exit Sub
    End If
    Set ts = fso.OpenTextFile(path, 1, False)
    Do Until ts.AtEndOfStream
        outFileObj.WriteLine ts.ReadLine
    Loop
    ts.Close
End Sub

Sub DumpQuery(dbObj, sql, outFileObj)
    Dim rs, i, line, v
    On Error Resume Next
    Set rs = dbObj.OpenRecordset(sql)
    If Err.Number <> 0 Then
        outFileObj.WriteLine "ERROR consulta: " & Err.Description & " SQL=" & sql
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If
    On Error GoTo 0
    If rs.EOF Then outFileObj.WriteLine "(sin registros)"
    Do Until rs.EOF
        line = ""
        For i = 0 To rs.Fields.Count - 1
            If IsNull(rs.Fields(i).Value) Then
                v = "NULL"
            Else
                v = CStr(rs.Fields(i).Value)
            End If
            If Len(v) > 100 Then v = Left(v, 100) & "..."
            line = line & rs.Fields(i).Name & "=" & v & " | "
        Next
        outFileObj.WriteLine line
        rs.MoveNext
    Loop
    rs.Close
End Sub

Function CountTable(dbObj, tableName)
    Dim rs, sql
    On Error Resume Next
    sql = "SELECT COUNT(*) AS CANTIDAD FROM [" & Replace(tableName, "]", "]]") & "]"
    Set rs = dbObj.OpenRecordset(sql)
    If Err.Number <> 0 Then
        CountTable = "ERROR: " & Err.Description
        Err.Clear
    Else
        CountTable = CStr(rs.Fields("CANTIDAD").Value)
        rs.Close
    End If
    On Error GoTo 0
End Function
