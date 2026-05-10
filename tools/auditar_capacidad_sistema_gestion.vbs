' Auditoria de capacidad operativa del Sistema de Gestion.
' NO modifica nada. Solo cuenta registros y revisa configuraciones visibles.

Option Explicit
Dim fso, shell, basePath, empPath, outPath, outFile, dao, dbU, dbP

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
outPath = basePath & "\auditoria_capacidad_sistema_gestion.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "AUDITORIA DE CAPACIDAD OPERATIVA - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")
outFile.WriteLine "Este reporte NO modifica nada. Solo revisa si hay señales visibles de tope por cantidad de empleados, contratos, legajos, empresas o usuarios."
outFile.WriteLine ""

outFile.WriteLine "1) RUTAS"
outFile.WriteLine String(90, "-")
CheckFile "SistemaGestion.exe", basePath & "\SistemaGestion.exe"
CheckFile "Usuarios.mdb", basePath & "\Usuarios.mdb"
CheckFile "Personal.mdb", empPath & "\Personal.mdb"
CheckFile "ConfiguraSis.ini", basePath & "\ConfiguraSis.ini"
CheckFile "Configura.ini", basePath & "\Configura.ini"
outFile.WriteLine ""

outFile.WriteLine "2) REGISTRO - PARAMETROS VISIBLES"
outFile.WriteLine String(90, "-")
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\ListaCantEmp"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\VersionFechaDeCreada"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\PathAplicacion"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGral"
outFile.WriteLine ""

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR: No se pudo abrir motor DAO: " & Err.Description
    outFile.Close
    WScript.Echo "Auditoria generada con error DAO. Ver: " & outPath
    WScript.Quit 0
End If
On Error GoTo 0

outFile.WriteLine "3) BASE GENERAL USUARIOS.MDB"
outFile.WriteLine String(90, "-")
If fso.FileExists(basePath & "\Usuarios.mdb") Then
    On Error Resume Next
    Set dbU = dao.OpenDatabase(basePath & "\Usuarios.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Usuarios.mdb: " & Err.Description
        Err.Clear
    Else
        WriteCount dbU, "Usuarios"
        WriteCount dbU, "EmpHabil"
        WriteCount dbU, "EstEmp"
        WriteCount dbU, "Permisos"
        outFile.WriteLine ""
        outFile.WriteLine "EmpHabil:"
        DumpQuery dbU, "SELECT * FROM EmpHabil", outFile
        outFile.WriteLine ""
        outFile.WriteLine "EstEmp:"
        DumpQuery dbU, "SELECT * FROM EstEmp", outFile
        dbU.Close
    End If
    On Error GoTo 0
Else
    outFile.WriteLine "No existe Usuarios.mdb"
End If
outFile.WriteLine ""

outFile.WriteLine "4) BASE DE EMPRESA - CONTEOS ACTUALES"
outFile.WriteLine String(90, "-")
If fso.FileExists(empPath & "\Personal.mdb") Then
    On Error Resume Next
    Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "Tablas operativas:"
        WriteCount dbP, "Personas"
        WriteCount dbP, "Contrato"
        WriteCount dbP, "Legajo"
        WriteCount dbP, "Encabezados"
        WriteCount dbP, "Datos_Liquidacion"
        WriteCount dbP, "Licencias"
        WriteCount dbP, "MTSS"
        outFile.WriteLine ""
        outFile.WriteLine "Tablas maestras/estructura:"
        WriteCount dbP, "Conceptos"
        WriteCount dbP, "TiposLiquidacion"
        WriteCount dbP, "Cargos"
        WriteCount dbP, "Sectores"
        WriteCount dbP, "Sucursales"
        WriteCount dbP, "Valores"
        WriteCount dbP, "Funciones"
        WriteCount dbP, "Documentos_Exigidos"
        outFile.WriteLine ""
        outFile.WriteLine "Tabla Empresa:"
        DumpQuery dbP, "SELECT * FROM Empresa", outFile
        dbP.Close
    End If
    On Error GoTo 0
Else
    outFile.WriteLine "No existe Personal.mdb"
End If
outFile.WriteLine ""

outFile.WriteLine "5) ARCHIVOS DE CONFIGURACION - LINEAS RELEVANTES"
outFile.WriteLine String(90, "-")
FindInText basePath & "\ConfiguraSis.ini", Array("ValidacionLicencia", "ListaPC", "CodigoSistema", "ListaCantEmp", "Cantidad", "Cant", "Empleado", "Legajo", "Empresa")
FindInText basePath & "\Configura.ini", Array("Cantidad", "Cant", "Empleado", "Legajo", "Empresa")
outFile.WriteLine ""

outFile.WriteLine "6) LECTURA ORIENTATIVA"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Si no aparecen campos o configuraciones de maximo de empleados/legajos, no hay evidencia visible de tope por cantidad en las bases."
outFile.WriteLine "Si aparece un parametro como ListaCantEmp, suele referirse a cantidad/lista de empresas visibles, no necesariamente a cantidad de empleados."
outFile.WriteLine "La prueba definitiva es funcional: cargar empleados de prueba y verificar si el sistema bloquea en algun numero."
outFile.WriteLine ""
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Auditoria generada en: " & outPath

Sub CheckFile(label, path)
    If fso.FileExists(path) Then outFile.WriteLine "OK - " & label & ": " & path Else outFile.WriteLine "FALTA - " & label & ": " & path
End Sub

Sub ReadReg(path)
    Dim v
    On Error Resume Next
    v = shell.RegRead(path)
    If Err.Number <> 0 Then
        outFile.WriteLine path & " = (no encontrado)"
        Err.Clear
    Else
        outFile.WriteLine path & " = " & CStr(v)
    End If
    On Error GoTo 0
End Sub

Sub FindInText(path, terms)
    Dim ts, line, n, i
    If Not fso.FileExists(path) Then
        outFile.WriteLine "No existe: " & path
        Exit Sub
    End If
    Set ts = fso.OpenTextFile(path, 1, False)
    n = 0
    Do Until ts.AtEndOfStream
        line = ts.ReadLine
        n = n + 1
        For i = 0 To UBound(terms)
            If InStr(1, line, CStr(terms(i)), vbTextCompare) > 0 Then
                outFile.WriteLine path & " | linea=" & n & " | " & line
                Exit For
            End If
        Next
    Loop
    ts.Close
End Sub

Sub DumpQuery(dbObj, sql, outFileObj)
    Dim rs, i, line, v
    On Error Resume Next
    Set rs = dbObj.OpenRecordset(sql)
    If Err.Number <> 0 Then outFileObj.WriteLine "ERROR consulta: " & Err.Description & " | " & sql: Err.Clear: On Error GoTo 0: Exit Sub
    On Error GoTo 0
    If rs.EOF Then outFileObj.WriteLine "(sin registros)"
    Do Until rs.EOF
        line = ""
        For i = 0 To rs.Fields.Count - 1
            If IsNull(rs.Fields(i).Value) Then v = "NULL" Else v = CStr(rs.Fields(i).Value)
            If Len(v) > 120 Then v = Left(v, 120) & "..."
            line = line & rs.Fields(i).Name & "=" & v & " | "
        Next
        outFileObj.WriteLine line
        rs.MoveNext
    Loop
    rs.Close
End Sub

Sub WriteCount(dbObj, tableName)
    outFile.WriteLine tableName & "=" & CountTable(dbObj, tableName)
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
