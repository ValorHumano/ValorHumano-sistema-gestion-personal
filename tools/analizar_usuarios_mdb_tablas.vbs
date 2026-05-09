' Analiza estructura de Usuarios.mdb sin modificar datos.
' Genera tablas, cantidades y campos para ubicar donde se guardan las empresas.

Option Explicit

Dim fso, basePath, dbPath, outPath, dao, db, outFile
Dim tdf, fld, tableName, countValue

basePath = "C:\GNS Software\GNS Personal PRO"
dbPath = basePath & "\Usuarios.mdb"
outPath = basePath & "\analisis_usuarios_mdb_tablas.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "ANALISIS USUARIOS.MDB"
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
    outFile.WriteLine "ERROR creando DAO.DBEngine.120: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR DAO. Ver: " & outPath
    WScript.Quit 1
End If
Set db = dao.OpenDatabase(dbPath)
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo Usuarios.mdb: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR abriendo base. Ver: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

For Each tdf In db.TableDefs
    tableName = tdf.Name
    If Left(tableName, 4) <> "MSys" Then
        countValue = CountTable(db, tableName)
        outFile.WriteLine ""
        outFile.WriteLine "TABLA: " & tableName
        outFile.WriteLine "REGISTROS: " & countValue
        outFile.WriteLine "CAMPOS:"
        For Each fld In tdf.Fields
            outFile.WriteLine "  - " & fld.Name & " | tipo=" & fld.Type & " | requerido=" & fld.Required
        Next
    End If
Next

db.Close
outFile.WriteLine ""
outFile.WriteLine String(80, "-")
outFile.WriteLine "FIN DEL ANALISIS"
outFile.Close

WScript.Echo "Analisis generado en: " & outPath

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
