' Limpieza simple v3 de datos demo en Valor Humano\Personal.mdb.
' Ejecutar con doble clic. No requiere BAT.
' Crea respaldo automatico antes de limpiar.
' V3 usa sintaxis valida de VBScript: no usa On Error GoTo etiqueta.

Option Explicit

Dim fso, basePath, dbPath, lockPath, respaldosPath, backupPath, logPath
Dim dao, wrk, db, outFile, tables, tableList, i, t, antes, despues, totalAntes, stamp
Dim hadError, errMsg, errTable

basePath = "C:\GNS Software\GNS Personal PRO\Valor Humano"
dbPath = basePath & "\Personal.mdb"
lockPath = basePath & "\Personal.ldb"
respaldosPath = basePath & "\Respaldos"
stamp = Timestamp()
backupPath = respaldosPath & "\Personal_BACKUP_AUTO_ANTES_LIMPIEZA_SIMPLE_V3_" & stamp & ".mdb"
logPath = basePath & "\limpieza_simple_v3_valor_humano_" & stamp & ".txt"

Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FolderExists(basePath) Then
    WScript.Echo "ERROR: No existe la carpeta: " & basePath
    WScript.Quit 1
End If

Set outFile = fso.CreateTextFile(logPath, True)
outFile.WriteLine "LIMPIEZA SIMPLE V3 BASE VALOR HUMANO"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & dbPath
outFile.WriteLine String(90, "-")

If Not fso.FileExists(dbPath) Then
    outFile.WriteLine "ERROR: No existe Personal.mdb"
    outFile.Close
    WScript.Echo "ERROR: No existe Personal.mdb. Ver: " & logPath
    WScript.Quit 1
End If

If fso.FileExists(lockPath) Then
    outFile.WriteLine "ERROR: Existe Personal.ldb. Cierre GNS Personal PRO antes de limpiar."
    outFile.Close
    WScript.Echo "ERROR: La base esta abierta. Cierre GNS Personal PRO. Ver: " & logPath
    WScript.Quit 1
End If

If Not fso.FolderExists(respaldosPath) Then
    fso.CreateFolder(respaldosPath)
End If

On Error Resume Next
fso.CopyFile dbPath, backupPath, True
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando respaldo: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR creando respaldo. Ver: " & logPath
    WScript.Quit 1
End If
On Error GoTo 0
outFile.WriteLine "Respaldo automatico creado: " & backupPath
outFile.WriteLine ""

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando DAO.DBEngine.120: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR DAO. Ver: " & logPath
    WScript.Quit 1
End If
Set wrk = dao.Workspaces(0)
Set db = dao.OpenDatabase(dbPath)
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR abriendo base: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR abriendo base. Ver: " & logPath
    WScript.Quit 1
End If
On Error GoTo 0

' Orden: dependencias e historicos primero; tablas padre al final.
tableList = "ArchVincFunc|AuxCostoEmp|AuxDatosExcel|AuxDeducciones|AuxDetaIRPF|AuxDetaSV|AuxDetaSVDeta|AuxEncIRPF|AuxFocer|AuxHistLab|AuxHistLabObras|AuxHistLabPrev|AuxHLActu|AuxHLComp|AuxImpPagos|AuxMTSSDeta|AuxMTSSObs|AuxMTSSRem|AuxOtrosRep|AuxTablaParaRepBSE|Avisos|Calendario_Liq|CierraMeses|ContratoAportaX|ContratosEnSeguro|Declaraciones|Datos_deAportes|Datos_Liquidacion|ImagenEmp|Impresion|Legajo|LegajoDatoModif|LegajoEmpresa|Licencias|LotesHistorico|LotesRepEsp|Lotes|MensajesEnRec|MTSSObs|MTSSRem|MTSSDeta|MTSS|PagosEnSueldoDeta|PagosEnSueldo|PersonasRela|PlanificDeLicencia|rCC_Cont|rContRepEsp|rEmpleado_Documentos|rLic_Enc|rPersonas_Dto_Comunicacion|rPlanillas|SueldosConf|WebContHabil|WebDatosExp|AuxContrato|Encabezados|Memos|Contrato|Personas"
tables = Split(tableList, "|")

totalAntes = 0
hadError = False
errMsg = ""
errTable = ""

outFile.WriteLine "TABLAS LIMPIADAS"
outFile.WriteLine String(90, "-")

On Error Resume Next
wrk.BeginTrans
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR iniciando transaccion: " & Err.Description
    outFile.Close
    db.Close
    WScript.Echo "ERROR iniciando transaccion. Ver: " & logPath
    WScript.Quit 1
End If
On Error GoTo 0

For i = 0 To UBound(tables)
    t = CStr(tables(i))
    antes = CountTable(db, t)
    If IsNumeric(antes) Then totalAntes = totalAntes + CLng(antes)

    On Error Resume Next
    db.Execute "DELETE FROM [" & Replace(t, "]", "]]") & "]", 128
    If Err.Number <> 0 Then
        hadError = True
        errMsg = Err.Description
        errTable = t
        Err.Clear
        On Error GoTo 0
        Exit For
    End If
    On Error GoTo 0

    despues = CountTable(db, t)
    outFile.WriteLine PadRight(CStr(t), 35) & " antes=" & antes & " despues=" & despues
Next

If hadError Then
    On Error Resume Next
    wrk.Rollback
    On Error GoTo 0
    outFile.WriteLine ""
    outFile.WriteLine "ERROR. SE REVERTIO LA TRANSACCION."
    outFile.WriteLine "Tabla: " & errTable
    outFile.WriteLine "Error: " & errMsg
    outFile.WriteLine "Respaldo disponible: " & backupPath
    outFile.Close
    db.Close
    WScript.Echo "ERROR durante limpieza. Se revirtio. Ver log: " & logPath
    WScript.Quit 1
Else
    On Error Resume Next
    wrk.CommitTrans
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR confirmando transaccion: " & Err.Description
        outFile.Close
        db.Close
        WScript.Echo "ERROR confirmando transaccion. Ver: " & logPath
        WScript.Quit 1
    End If
    On Error GoTo 0
End If

outFile.WriteLine String(90, "-")
outFile.WriteLine "LIMPIEZA COMPLETADA CORRECTAMENTE"
outFile.WriteLine "Total registros limpiados estimados: " & totalAntes
outFile.WriteLine "Respaldo: " & backupPath
outFile.Close

db.Close
WScript.Echo "Limpieza completada correctamente. Ver log: " & logPath
WScript.Quit 0

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

Function PadRight(s, n)
    If Len(s) >= n Then
        PadRight = s
    Else
        PadRight = s & Space(n - Len(s))
    End If
End Function

Function Timestamp()
    Timestamp = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & "_" & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
End Function
