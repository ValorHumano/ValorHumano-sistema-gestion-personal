' Simula limpieza de datos demo en Valor Humano\Personal.mdb.
' NO modifica datos. Genera reporte con tablas y registros que se limpiarian.

Option Explicit

Dim fso, basePath, dbPath, outPath, outFile, dao, db
Dim tables, i, t, countValue, total

basePath = "C:\GNS Software\GNS Personal PRO\Valor Humano"
dbPath = basePath & "\Personal.mdb"
outPath = basePath & "\simulacion_limpieza_valor_humano.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "SIMULACION DE LIMPIEZA - VALOR HUMANO"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & dbPath
outFile.WriteLine String(80, "-")

If Not fso.FileExists(dbPath) Then
    outFile.WriteLine "ERROR: No existe la base."
    outFile.Close
    WScript.Echo "ERROR: No existe la base. Ver: " & outPath
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
    outFile.WriteLine "ERROR abriendo base: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR abriendo base. Ver: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

' Orden: tablas hijas primero, tablas padre al final.
tables = Array( _
"ArchVincFunc", _
"AuxContrato", _
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
"Encabezados", _
"ImagenEmp", _
"Impresion", _
"Legajo", _
"LegajoDatoModif", _
"LegajoEmpresa", _
"Licencias", _
"Lotes", _
"LotesHistorico", _
"LotesRepEsp", _
"Memos", _
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
"Contrato", _
"Personas" _
)

total = 0
For i = 0 To UBound(tables)
    t = tables(i)
    countValue = CountTable(db, t)
    If IsNumeric(countValue) Then total = total + CLng(countValue)
    outFile.WriteLine PadRight(CStr(t), 35) & " registros_actuales=" & countValue
Next

outFile.WriteLine String(80, "-")
outFile.WriteLine "TOTAL REGISTROS QUE SE LIMPIARIAN: " & total
outFile.WriteLine ""
outFile.WriteLine "ESTO FUE SOLO SIMULACION. NO SE MODIFICO LA BASE."
outFile.WriteLine "Si el reporte es correcto, ejecutar limpiar_base_valor_humano.bat."

db.Close
outFile.Close
WScript.Echo "Simulacion generada en: " & outPath

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
