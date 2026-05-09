' Lee tablas clave de Usuarios.mdb para identificar empresas y permisos.
' No modifica datos.

Option Explicit

Dim fso, basePath, dbPath, outPath, dao, db, outFile

basePath = "C:\GNS Software\GNS Personal PRO"
dbPath = basePath & "\Usuarios.mdb"
outPath = basePath & "\usuarios_empresas_mdb.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "LECTURA TABLAS CLAVE USUARIOS.MDB"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & dbPath
outFile.WriteLine String(80, "-")

If Not fso.FileExists(dbPath) Then
    outFile.WriteLine "ERROR: No existe Usuarios.mdb"
    outFile.Close
    WScript.Echo "ERROR: No existe Usuarios.mdb. Ver: " & outPath
    WScript.Quit 1
End If

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR DAO: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR DAO. Ver: " & outPath
    WScript.Quit 1
End If
Set db = dao.OpenDatabase(dbPath)
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo base: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR abriendo base. Ver: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

DumpTable db, outFile, "Usuarios"
DumpTable db, outFile, "EmpHabil"
DumpTable db, outFile, "EstEmp"
DumpTable db, outFile, "EmpresasVinc"
DumpTable db, outFile, "Registro"

db.Close
outFile.WriteLine ""
outFile.WriteLine String(80, "-")
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Archivo generado en: " & outPath

Sub DumpTable(dbObj, outFileObj, tableName)
    Dim rs, i, line, valueText
    outFileObj.WriteLine ""
    outFileObj.WriteLine "TABLA: " & tableName
    outFileObj.WriteLine String(80, "-")
    On Error Resume Next
    Set rs = dbObj.OpenRecordset("SELECT * FROM [" & tableName & "]")
    If Err.Number <> 0 Then
        outFileObj.WriteLine "ERROR leyendo tabla: " & Err.Description
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If
    On Error GoTo 0

    If rs.EOF Then
        outFileObj.WriteLine "(sin registros)"
    End If

    Do Until rs.EOF
        line = ""
        For i = 0 To rs.Fields.Count - 1
            If IsNull(rs.Fields(i).Value) Then
                valueText = "NULL"
            Else
                valueText = CStr(rs.Fields(i).Value)
            End If
            If Len(valueText) > 120 Then valueText = Left(valueText, 120) & "..."
            line = line & rs.Fields(i).Name & "=" & valueText & " | "
        Next
        outFileObj.WriteLine line
        rs.MoveNext
    Loop
    rs.Close
End Sub
