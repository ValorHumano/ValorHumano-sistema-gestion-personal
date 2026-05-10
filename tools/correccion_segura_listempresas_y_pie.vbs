' Correccion segura posterior a auditoria profunda.
' Acciones seguras:
' 1) Deja ListEmpresas.ini y ListEmpresas con una sola entrada visible.
' 2) Limpia PieDeImpresion para que no salga GNS en recibos/informes.
' 3) Crea respaldos antes de tocar archivos/bases.
' NO toca ValidacionLicencia, CodigoSistema, ListaPC, CodPC ni controles de licencia.

Option Explicit

Dim fso, basePath, empPath, stamp, backupPath, outPath, outFile, dao, dbP
Dim listLine

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
stamp = Timestamp()
backupPath = basePath & "\_Backup_Correccion_Segura_" & stamp
outPath = basePath & "\correccion_segura_listempresas_y_pie_" & stamp & ".txt"
listLine = "C:\GNS Software\GNS Personal PRO\Valor Humano <-> Sistema de Gestion"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "CORRECCION SEGURA LISTEMPRESAS Y PIE DE IMPRESION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")

If Not fso.FolderExists(basePath) Then
    outFile.WriteLine "ERROR: No existe carpeta base: " & basePath
    outFile.Close
    MsgBox "ERROR: No existe carpeta base. Ver: " & outPath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If

If Not fso.FileExists(empPath & "\Personal.mdb") Then
    outFile.WriteLine "ERROR: No existe Personal.mdb en: " & empPath
    outFile.Close
    MsgBox "ERROR: No existe Personal.mdb. Ver: " & outPath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If

If Not fso.FolderExists(backupPath) Then fso.CreateFolder backupPath

outFile.WriteLine "1) RESPALDOS"
outFile.WriteLine String(90, "-")
BackupFile basePath & "\ListEmpresas.ini", backupPath & "\ListEmpresas.ini"
BackupFile basePath & "\ListEmpresas", backupPath & "\ListEmpresas"
BackupFile empPath & "\Personal.mdb", backupPath & "\Personal_Valor_Humano.mdb"
outFile.WriteLine ""

outFile.WriteLine "2) LISTEMPRESAS"
outFile.WriteLine String(90, "-")
WriteTextFile basePath & "\ListEmpresas.ini", listLine
WriteTextFile basePath & "\ListEmpresas", listLine
outFile.WriteLine "ListEmpresas.ini escrito con: " & listLine
outFile.WriteLine "ListEmpresas escrito con: " & listLine
outFile.WriteLine ""

outFile.WriteLine "3) PIE DE IMPRESION"
outFile.WriteLine String(90, "-")
On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando DAO.DBEngine.120: " & Err.Description
    outFile.Close
    MsgBox "ERROR DAO. Ver: " & outPath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If
Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
    outFile.Close
    MsgBox "ERROR abriendo Personal.mdb. Ver: " & outPath, 16, "Sistema de Gestion"
    WScript.Quit 1
End If
On Error GoTo 0

On Error Resume Next
dbP.Execute "UPDATE Empresa SET PieDeImpresion='Sistema de Gestion'", 128
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR actualizando PieDeImpresion: " & Err.Description
    Err.Clear
Else
    outFile.WriteLine "PieDeImpresion actualizado a: Sistema de Gestion"
End If
On Error GoTo 0

outFile.WriteLine ""
outFile.WriteLine "Tabla Empresa despues del cambio:"
DumpQuery dbP, "SELECT Nombre, RazonSocial, RUC, PieDeImpresion FROM Empresa", outFile
dbP.Close

outFile.WriteLine ""
outFile.WriteLine "4) RESULTADO"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Correccion aplicada. No se tocaron ValidacionLicencia, CodigoSistema, ListaPC ni CodPC."
outFile.WriteLine "Respaldo creado en: " & backupPath
outFile.WriteLine "Ahora ejecute auditar_dependencias_ocx_sistema_gestion.vbs para revisar componentes."
outFile.WriteLine "FIN"
outFile.Close

MsgBox "Correccion segura aplicada. Ver reporte: " & outPath, 64, "Sistema de Gestion"

Sub BackupFile(src, dst)
    On Error Resume Next
    If fso.FileExists(src) Then
        fso.CopyFile src, dst, True
        If Err.Number = 0 Then
            outFile.WriteLine "OK backup: " & src & " -> " & dst
        Else
            outFile.WriteLine "ERROR backup: " & src & " -> " & Err.Description
            Err.Clear
        End If
    Else
        outFile.WriteLine "NO existe para backup: " & src
    End If
    On Error GoTo 0
End Sub

Sub WriteTextFile(path, text)
    Dim ts
    Set ts = fso.CreateTextFile(path, True)
    ts.WriteLine text
    ts.Close
End Sub

Sub DumpQuery(dbObj, sql, outFileObj)
    Dim rs, i, line, v
    On Error Resume Next
    Set rs = dbObj.OpenRecordset(sql)
    If Err.Number <> 0 Then
        outFileObj.WriteLine "ERROR consulta: " & Err.Description & " | " & sql
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If
    On Error GoTo 0
    If rs.EOF Then outFileObj.WriteLine "(sin registros)"
    Do Until rs.EOF
        line = ""
        For i = 0 To rs.Fields.Count - 1
            If IsNull(rs.Fields(i).Value) Then v = "NULL" Else v = CStr(rs.Fields(i).Value)
            If Len(v) > 160 Then v = Left(v, 160) & "..."
            line = line & rs.Fields(i).Name & "=" & v & " | "
        Next
        outFileObj.WriteLine line
        rs.MoveNext
    Loop
    rs.Close
End Sub

Function Timestamp()
    Timestamp = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & "_" & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
End Function
