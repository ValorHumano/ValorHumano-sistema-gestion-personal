' Analiza la estructura de la base Access de Valor Humano sin modificar datos.
' Genera un TXT con tablas, cantidad de registros y campos.

Option Explicit

Dim fso, basePath, dbPath, outPath, conn, rsTables, rsCols, outFile
Dim tableName, tableType, sql, rsCount, countValue

Set fso = CreateObject("Scripting.FileSystemObject")
basePath = "C:\GNS Software\GNS Personal PRO\Valor Humano"
dbPath = basePath & "\Personal.mdb"
outPath = basePath & "\estructura_base_valor_humano.txt"

If Not fso.FileExists(dbPath) Then
    WScript.Echo "ERROR: No existe la base: " & dbPath
    WScript.Quit 1
End If

Set outFile = fso.CreateTextFile(outPath, True)
outFile.WriteLine "ESTRUCTURA BASE VALOR HUMANO"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & dbPath
outFile.WriteLine String(80, "-")

Set conn = CreateObject("ADODB.Connection")
On Error Resume Next
conn.Open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & dbPath & ";"
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo base con Jet OLEDB 4.0: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR abriendo base. Ver archivo: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

Set rsTables = conn.OpenSchema(20)

outFile.WriteLine "TABLAS DE USUARIO"
outFile.WriteLine String(80, "-")

Do Until rsTables.EOF
    tableName = CStr(rsTables.Fields("TABLE_NAME").Value)
    tableType = CStr(rsTables.Fields("TABLE_TYPE").Value)

    If tableType = "TABLE" Then
        If Left(tableName, 4) <> "MSys" Then
            countValue = "NO_CALCULADO"
            On Error Resume Next
            sql = "SELECT COUNT(*) AS CANTIDAD FROM [" & Replace(tableName, "]", "]]" ) & "]"
            Set rsCount = conn.Execute(sql)
            If Err.Number = 0 Then
                countValue = CStr(rsCount.Fields("CANTIDAD").Value)
                rsCount.Close
            Else
                countValue = "ERROR_COUNT: " & Err.Description
                Err.Clear
            End If
            On Error GoTo 0

            outFile.WriteLine ""
            outFile.WriteLine "TABLA: " & tableName
            outFile.WriteLine "REGISTROS: " & countValue
            outFile.WriteLine "CAMPOS:"

            On Error Resume Next
            Set rsCols = conn.OpenSchema(4, Array(Empty, Empty, tableName, Empty))
            If Err.Number = 0 Then
                Do Until rsCols.EOF
                    outFile.WriteLine "  - " & rsCols.Fields("COLUMN_NAME").Value & " | tipo=" & rsCols.Fields("DATA_TYPE").Value & " | nullable=" & rsCols.Fields("IS_NULLABLE").Value
                    rsCols.MoveNext
                Loop
                rsCols.Close
            Else
                outFile.WriteLine "  ERROR leyendo campos: " & Err.Description
                Err.Clear
            End If
            On Error GoTo 0
        End If
    End If

    rsTables.MoveNext
Loop

rsTables.Close
conn.Close
outFile.WriteLine ""
outFile.WriteLine String(80, "-")
outFile.WriteLine "FIN DEL ANALISIS"
outFile.Close

WScript.Echo "Analisis generado en: " & outPath
