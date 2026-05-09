' Analiza la estructura de la base Access de Valor Humano usando DAO.
' No modifica datos. Alternativa cuando Jet OLEDB no esta disponible.

Option Explicit

Dim fso, basePath, dbPath, outPath, outFile
Dim dao, db, tdf, fld, rs
Dim tableName, countValue, sql

Set fso = CreateObject("Scripting.FileSystemObject")
basePath = "C:\GNS Software\GNS Personal PRO\Valor Humano"
dbPath = basePath & "\Personal.mdb"
outPath = basePath & "\estructura_base_valor_humano_dao.txt"

If Not fso.FileExists(dbPath) Then
    WScript.Echo "ERROR: No existe la base: " & dbPath
    WScript.Quit 1
End If

Set outFile = fso.CreateTextFile(outPath, True)
outFile.WriteLine "ESTRUCTURA BASE VALOR HUMANO - DAO"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & dbPath
outFile.WriteLine String(80, "-")

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.36")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando DAO.DBEngine.36: " & Err.Description
    Err.Clear
    Set dao = Nothing
End If

If dao Is Nothing Then
    Set dao = CreateObject("DAO.DBEngine.120")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR creando DAO.DBEngine.120: " & Err.Description
        outFile.WriteLine "No se pudo abrir la base con DAO."
        outFile.Close
        WScript.Echo "ERROR DAO. Ver archivo: " & outPath
        WScript.Quit 1
    End If
End If
On Error GoTo 0

On Error Resume Next
Set db = dao.OpenDatabase(dbPath)
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo base con DAO: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR abriendo base DAO. Ver archivo: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

outFile.WriteLine "TABLAS DE USUARIO"
outFile.WriteLine String(80, "-")

For Each tdf In db.TableDefs
    tableName = tdf.Name
    If Left(tableName, 4) <> "MSys" Then
        If (tdf.Attributes And &H80000000) = 0 Then
            countValue = "NO_CALCULADO"
            On Error Resume Next
            sql = "SELECT COUNT(*) AS CANTIDAD FROM [" & Replace(tableName, "]", "]]" ) & "]"
            Set rs = db.OpenRecordset(sql)
            If Err.Number = 0 Then
                countValue = CStr(rs.Fields("CANTIDAD").Value)
                rs.Close
            Else
                countValue = "ERROR_COUNT: " & Err.Description
                Err.Clear
            End If
            On Error GoTo 0

            outFile.WriteLine ""
            outFile.WriteLine "TABLA: " & tableName
            outFile.WriteLine "REGISTROS: " & countValue
            outFile.WriteLine "CAMPOS:"

            For Each fld In tdf.Fields
                outFile.WriteLine "  - " & fld.Name & " | tipo=" & fld.Type & " | requerido=" & fld.Required
            Next
        End If
    End If
Next

db.Close
outFile.WriteLine ""
outFile.WriteLine String(80, "-")
outFile.WriteLine "FIN DEL ANALISIS"
outFile.Close

WScript.Echo "Analisis DAO generado en: " & outPath
