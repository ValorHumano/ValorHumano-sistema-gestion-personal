' Limpieza real de datos demo en Valor Humano\Personal.mdb.
' Crea respaldo automatico antes de limpiar.
' Usa transaccion: si una tabla falla, revierte todo.

Option Explicit

Dim fso, basePath, dbPath, lockPath, respaldosPath, backupPath, logPath
Dim dao, wrk, db, outFile, tables, i, t, beforeCount, afterCount, totalBefore
Dim stamp

basePath = "C:\GNS Software\GNS Personal PRO\Valor Humano"
dbPath = basePath & "\Personal.mdb"
lockPath = basePath & "\Personal.ldb"
respaldosPath = basePath & "\Respaldos"
stamp = Timestamp()
backupPath = respaldosPath & "\Personal_BACKUP_AUTO_ANTES_LIMPIEZA_" & stamp & ".mdb"
logPath = basePath & "\limpieza_valor_humano_" & stamp & ".txt"

Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FolderExists(basePath) Then
    WScript.Echo "ERROR: No existe la carpeta: " & basePath
    WScript.Quit 1
End If

Set outFile = fso.CreateTextFile(logPath, True)
outFile.WriteLine "LIMPIEZA REAL BASE VALOR HUMANO"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & dbPath
outFile.WriteLine String(90, "-")

If Not fso.FileExists(dbPath) Then
    outFile.WriteLine "ERROR: No existe la base."
    outFile.Close
    WScript.Echo "ERROR: No existe la base. Ver: " & logPath
    WScript.Quit 1
End If

If fso.FileExists(lockPath) Then
    outFile.WriteLine "ERROR: Existe archivo de bloqueo Personal.ldb. Cierre GNS Personal PRO y vuelva a ejecutar."
    outFile.Close
    WScript.Echo "ERROR: La base parece estar abierta. Cierre GNS Personal PRO. Ver: " & logPath
    WScript.Quit 1
End If

If Not fso.FolderExists(respaldosPath) Then
    fso.CreateFolder(respaldosPath)
End If

outFile.WriteLine "Creando respaldo automatico: " & backupPath
On Error Resume Next
fso.CopyFile dbPath, backupPath, True
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando respaldo: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR creando respaldo. Ver: " & logPath
    WScript.Quit 1
End If
On Error GoTo 0
outFile.WriteLine "Respaldo creado correctamente."
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

' Orden: tablas hijas/relaciones primero; Personas y Contrato al final.
tables = Array( _
"ArchVincFunc", _
"AuxCostoEmp", _
"AuxDatosExcel", _
"AuxDeducciones", _
"AuxDetaIRPF", _
"AuxDetaSV", _
"AuxDetaSVDeta", _
"AuxEncIRPF", _
"AuxFocer", _
"AuxHistLab", _
"AuxHistLabObras", _
"AuxHistLabPrev", _
"AuxHLActu", _
"AuxHLComp", _
"AuxImpPagos", _
"AuxMTSSDeta", _
"AuxMTSSObs", _
"AuxMTSSRem", _
"AuxOtrosRep", _
"AuxTablaParaRepBSE", _
"Avisos", _
"Calendario_Liq", _
"CierraMeses", _
"ContratoAportaX", _
"ContratosEnSeguro", _
"Declaraciones", _
"Datos_deAportes", _
"Datos_Liquidacion", _
"ImagenEmp", _
"Impresion", _
"Legajo", _
"LegajoDatoModif", _
"LegajoEmpresa", _
"Licencias", _
"LotesHistorico", _
"LotesRepEsp", _
"Lotes", _
"MensajesEnRec", _
"MTSSObs", _
"MTSSRem", _
"MTSSDeta", _
"MTSS", _
"PagosEnSueldoDeta", _
"PagosEnSueldo", _
"PersonasRela", _
"PlanificDeLicencia", _
"rCC_Cont", _
"rContRepEsp", _
"rEmpleado_Documentos", _
"rLic_Enc", _
"rPersonas_Dto_Comunicacion", _
"rPlanillas", _
"SueldosConf", _
"WebContHabil", _
"WebDatosExp", _
"AuxContrato", _
"Encabezados", _
"Memos", _
"Contrato", _
"Personas" _
)

totalBefore = 0
outFile.WriteLine "TABLAS A LIMPIAR"
outFile.WriteLine String(90, "-")

On Error GoTo CleanError
wrk.BeginTrans

For i = 0 To UBound(tables)
    t = tables(i)
    beforeCount = CountTable(db, t)
    If IsNumeric(beforeCount) Then totalBefore = totalBefore + CLng(beforeCount)
    db.Execute "DELETE * FROM [" & Replace(t, "]", "]]" ) & "]", 128
    afterCount = CountTable(db, t)
    outFile.WriteLine PadRight(CStr(t), 35) & " antes=" & beforeCount & " despues=" & afterCount
Next

wrk.CommitTrans
outFile.WriteLine String(90, "-")
outFile.WriteLine "LIMPIEZA COMPLETADA CORRECTAMENTE."
outFile.WriteLine "Total registros limpiados estimados: " & totalBefore
outFile.WriteLine "Respaldo automatico: " & backupPath
outFile.WriteLine ""
outFile.WriteLine "Siguiente paso: abrir GNS Personal PRO y verificar que la empresa Valor Humano abra sin empleados demo."
outFile.Close

db.Close
WScript.Echo "Limpieza completada correctamente. Log: " & logPath
WScript.Quit 0

CleanError:
    On Error Resume Next
    wrk.Rollback
    outFile.WriteLine ""
    outFile.WriteLine "ERROR DURANTE LA LIMPIEZA. SE REVERTIO LA TRANSACCION."
    outFile.WriteLine "Tabla actual: " & t
    outFile.WriteLine "Error: " & Err.Description
    outFile.WriteLine "La base no deberia haber quedado modificada. Respaldo disponible: " & backupPath
    outFile.Close
    If Not db Is Nothing Then db.Close
    WScript.Echo "ERROR durante limpieza. Se revirtio. Ver log: " & logPath
    WScript.Quit 1

Function CountTable(dbObj, tableName)
    Dim rs, sql
    On Error Resume Next
    sql = "SELECT COUNT(*) AS CANTIDAD FROM [" & Replace(tableName, "]", "]]" ) & "]"
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
