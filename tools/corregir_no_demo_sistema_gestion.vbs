' Corrige restos visibles de demo en el Sistema de Gestion local.
' Hace respaldo previo. No toca codigos internos de empresa/permisos.
' Acciones:
' - Reescribe ListEmpresas.ini y ListEmpresas con una sola entrada visible.
' - Oculta carpetas de empresas demo/restantes moviendolas a _Empresas_Ocultas.
' - Limpia datos institucionales demo en Usuarios.mdb y Valor Humano\Personal.mdb.

Option Explicit

Dim fso, basePath, empPath, stamp, backupPath, ocultasPath, outPath, outFile
Dim dao, dbU, dbP, listLine

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
stamp = Timestamp()
backupPath = basePath & "\_Backup_Antes_NoDemo_" & stamp
ocultasPath = basePath & "\_Empresas_Ocultas"
outPath = basePath & "\correccion_no_demo_sistema_gestion_" & stamp & ".txt"
listLine = "C:\GNS Software\GNS Personal PRO\Valor Humano <-> Sistema de Gestion"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "CORRECCION NO-DEMO - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")

If Not fso.FolderExists(basePath) Then
    outFile.WriteLine "ERROR: No existe carpeta base: " & basePath
    outFile.Close
    WScript.Echo "ERROR: No existe carpeta base. Ver: " & outPath
    WScript.Quit 1
End If

If Not fso.FileExists(empPath & "\Personal.mdb") Then
    outFile.WriteLine "ERROR: No existe base de empresa: " & empPath & "\Personal.mdb"
    outFile.Close
    WScript.Echo "ERROR: No existe Personal.mdb. Ver: " & outPath
    WScript.Quit 1
End If

If Not fso.FolderExists(backupPath) Then fso.CreateFolder backupPath
If Not fso.FolderExists(ocultasPath) Then fso.CreateFolder ocultasPath

outFile.WriteLine "1) RESPALDOS"
outFile.WriteLine String(90, "-")
BackupFile basePath & "\Usuarios.mdb", backupPath & "\Usuarios.mdb"
BackupFile empPath & "\Personal.mdb", backupPath & "\Personal_Valor_Humano.mdb"
BackupFile basePath & "\ListEmpresas.ini", backupPath & "\ListEmpresas.ini"
BackupFile basePath & "\ListEmpresas", backupPath & "\ListEmpresas"
outFile.WriteLine ""

outFile.WriteLine "2) LISTEMPRESAS"
outFile.WriteLine String(90, "-")
WriteTextFile basePath & "\ListEmpresas.ini", listLine
WriteTextFile basePath & "\ListEmpresas", listLine
outFile.WriteLine "ListEmpresas.ini y ListEmpresas reescritos con: " & listLine
outFile.WriteLine ""

outFile.WriteLine "3) OCULTAR EMPRESAS QUE NO DEBEN APARECER"
outFile.WriteLine String(90, "-")
HideFolderIfExists basePath & "\El Refugio", ocultasPath & "\El Refugio_" & stamp
HideFolderIfExists basePath & "\Generica", ocultasPath & "\Generica_" & stamp
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

outFile.WriteLine "4) LIMPIAR BASE GENERAL USUARIOS.MDB"
outFile.WriteLine String(90, "-")
If fso.FileExists(basePath & "\Usuarios.mdb") Then
    On Error Resume Next
    Set dbU = dao.OpenDatabase(basePath & "\Usuarios.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Usuarios.mdb: " & Err.Description
        Err.Clear
    Else
        ExecSQL dbU, "UPDATE EstEmp SET Nombre='Sistema de Gestion', RazonSocial='', RUT='', Email='', EMailGest=''"
        outFile.WriteLine "EstEmp actualizado: Nombre='Sistema de Gestion'; datos demo eliminados."
        dbU.Close
    End If
    On Error GoTo 0
Else
    outFile.WriteLine "Usuarios.mdb no existe."
End If
outFile.WriteLine ""

outFile.WriteLine "5) LIMPIAR DATOS DEMO EN BASE DE EMPRESA"
outFile.WriteLine String(90, "-")
On Error Resume Next
Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
    Err.Clear
Else
    ExecSQL dbP, "UPDATE Empresa SET Nombre='Sistema de Gestion', RazonSocial='', Direccion='', RUC='', Email='', Telefono1='', Fax='', Contacto1='', NombreGest='', DirecGest='', TelefonoGest='', FaxGest='', ContactoGest='', EMailGest='', Ramo='', PieDeImpresion='Sistema de Gestion'"
    outFile.WriteLine "Tabla Empresa actualizada: nombre visual Sistema de Gestion; datos demo eliminados."
    outFile.WriteLine "Conteos operativos: Personas=" & CountTable(dbP, "Personas") & ", Contrato=" & CountTable(dbP, "Contrato") & ", Liquidaciones=" & CountTable(dbP, "Encabezados")
    dbP.Close
End If
On Error GoTo 0
outFile.WriteLine ""

outFile.WriteLine "6) RESULTADO"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Correccion aplicada. Abra el sistema desde SistemaGestion.exe y verifique el selector."
outFile.WriteLine "Debe aparecer una sola empresa visible: Sistema de Gestion."
outFile.WriteLine "Respaldo creado en: " & backupPath
outFile.WriteLine "Empresas ocultas en: " & ocultasPath
outFile.WriteLine ""
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Correccion aplicada. Ver reporte: " & outPath

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

Sub HideFolderIfExists(src, dst)
    On Error Resume Next
    If fso.FolderExists(src) Then
        If fso.FolderExists(dst) Then dst = dst & "_2"
        fso.MoveFolder src, dst
        If Err.Number = 0 Then
            outFile.WriteLine "OK oculta: " & src & " -> " & dst
        Else
            outFile.WriteLine "ERROR ocultando: " & src & " -> " & Err.Description
            Err.Clear
        End If
    Else
        outFile.WriteLine "No existe carpeta a ocultar: " & src
    End If
    On Error GoTo 0
End Sub

Sub ExecSQL(dbObj, sql)
    On Error Resume Next
    dbObj.Execute sql, 128
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR SQL: " & Err.Description & " | " & sql
        Err.Clear
    End If
    On Error GoTo 0
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

Function Timestamp()
    Timestamp = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & "_" & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
End Function
