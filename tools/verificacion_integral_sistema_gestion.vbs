' Verificacion integral del Sistema de Gestion local.
' No modifica datos. Genera reporte de instalacion, demo, base, tablas y dependencias.

Option Explicit

Dim fso, basePath, empPath, outPath, outFile, dao, dbU, dbP
Dim exePath, oldExePath

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
exePath = basePath & "\SistemaGestion.exe"
oldExePath = basePath & "\GnsPersonal.exe"
outPath = basePath & "\verificacion_integral_sistema_gestion.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "VERIFICACION INTEGRAL - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")

outFile.WriteLine "1) RUTAS Y EJECUTABLES"
outFile.WriteLine String(90, "-")
WriteCheck "Carpeta base existe", fso.FolderExists(basePath), basePath
WriteCheck "SistemaGestion.exe existe", fso.FileExists(exePath), exePath
WriteCheck "GnsPersonal.exe original existe", fso.FileExists(oldExePath), oldExePath
WriteCheck "Usuarios.mdb existe", fso.FileExists(basePath & "\Usuarios.mdb"), basePath & "\Usuarios.mdb"
WriteCheck "Valor Humano existe", fso.FolderExists(empPath), empPath
WriteCheck "Valor Humano\Personal.mdb existe", fso.FileExists(empPath & "\Personal.mdb"), empPath & "\Personal.mdb"
outFile.WriteLine ""

outFile.WriteLine "2) LISTA FISICA DE EMPRESAS DETECTADAS"
outFile.WriteLine String(90, "-")
ListCompanyFolders basePath, outFile
outFile.WriteLine ""

outFile.WriteLine "3) LISTEMPRESAS"
outFile.WriteLine String(90, "-")
outFile.WriteLine "ListEmpresas.ini:"
DumpFile basePath & "\ListEmpresas.ini", outFile
outFile.WriteLine ""
outFile.WriteLine "ListEmpresas sin extension:"
DumpFile basePath & "\ListEmpresas", outFile
outFile.WriteLine ""

outFile.WriteLine "4) DEPENDENCIAS PRINCIPALES"
outFile.WriteLine String(90, "-")
CheckFile "BtnDibu4.ocx"
CheckFile "OtrosObjZinco.ocx"
CheckFile "ZincoGrid.ocx"
CheckFile "PaComunicar.ocx"
CheckFile "ControlParaRep.ocx"
CheckFile "crviewer9.dll"
CheckFile "DllConexion.dll"
CheckFile "DllConexion4.dll"
CheckFile "LibGeneral.dll"
CheckFile "FuncionesVarias.dll"
CheckFile "FuncionesVarias4.dll"
outFile.WriteLine ""

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR DAO.DBEngine.120: " & Err.Description
    outFile.Close
    WScript.Echo "ERROR DAO. Ver: " & outPath
    WScript.Quit 1
End If
On Error GoTo 0

outFile.WriteLine "5) BASE GENERAL USUARIOS.MDB"
outFile.WriteLine String(90, "-")
If fso.FileExists(basePath & "\Usuarios.mdb") Then
    On Error Resume Next
    Set dbU = dao.OpenDatabase(basePath & "\Usuarios.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Usuarios.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "Usuarios=" & CountTable(dbU, "Usuarios")
        outFile.WriteLine "EmpHabil=" & CountTable(dbU, "EmpHabil")
        outFile.WriteLine "EstEmp=" & CountTable(dbU, "EstEmp")
        outFile.WriteLine "Permisos=" & CountTable(dbU, "Permisos")
        outFile.WriteLine ""
        outFile.WriteLine "Registros EmpHabil:"
        DumpQuery dbU, "SELECT * FROM EmpHabil", outFile
        outFile.WriteLine ""
        outFile.WriteLine "Registros EstEmp:"
        DumpQuery dbU, "SELECT * FROM EstEmp", outFile
        dbU.Close
    End If
    On Error GoTo 0
Else
    outFile.WriteLine "NO EXISTE Usuarios.mdb"
End If
outFile.WriteLine ""

outFile.WriteLine "6) BASE DE EMPRESA VALOR HUMANO"
outFile.WriteLine String(90, "-")
If fso.FileExists(empPath & "\Personal.mdb") Then
    On Error Resume Next
    Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "Tabla Empresa:"
        DumpQuery dbP, "SELECT * FROM Empresa", outFile
        outFile.WriteLine ""
        outFile.WriteLine "Tablas operativas que deberian estar limpias o con datos reales cargados manualmente:"
        WriteCount dbP, "Personas"
        WriteCount dbP, "Contrato"
        WriteCount dbP, "Encabezados"
        WriteCount dbP, "Datos_Liquidacion"
        WriteCount dbP, "Datos_deAportes"
        WriteCount dbP, "Legajo"
        WriteCount dbP, "Licencias"
        WriteCount dbP, "PlanificDeLicencia"
        WriteCount dbP, "MTSS"
        WriteCount dbP, "PagosEnSueldo"
        outFile.WriteLine ""
        outFile.WriteLine "Tablas maestras necesarias:"
        WriteCount dbP, "Conceptos"
        WriteCount dbP, "TiposLiquidacion"
        WriteCount dbP, "Bancos"
        WriteCount dbP, "Cargos"
        WriteCount dbP, "Sectores"
        WriteCount dbP, "Sucursales"
        WriteCount dbP, "Localidades"
        WriteCount dbP, "Paises"
        WriteCount dbP, "Monedas"
        WriteCount dbP, "Valores"
        WriteCount dbP, "Funciones"
        WriteCount dbP, "Documentos_Exigidos"
        dbP.Close
    End If
    On Error GoTo 0
Else
    outFile.WriteLine "NO EXISTE Personal.mdb"
End If
outFile.WriteLine ""

outFile.WriteLine "7) RESULTADO ORIENTATIVO"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Este reporte verifica estructura, rutas, dependencias y datos."
outFile.WriteLine "Para afirmar que TODAS las herramientas funcionan hay que hacer prueba manual dentro del sistema:"
outFile.WriteLine "- abrir empresa"
outFile.WriteLine "- crear ficha de empleado"
outFile.WriteLine "- crear contrato"
outFile.WriteLine "- generar legajo"
outFile.WriteLine "- probar liquidacion"
outFile.WriteLine "- probar recibo/informe/impresion"
outFile.WriteLine "- probar licencia/BSE/MTSS si se van a usar"
outFile.WriteLine ""
outFile.WriteLine String(90, "-")
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Verificacion integral generada en: " & outPath

Sub WriteCheck(label, ok, detail)
    If ok Then
        outFile.WriteLine "OK  - " & label & " -> " & detail
    Else
        outFile.WriteLine "FALTA - " & label & " -> " & detail
    End If
End Sub

Sub CheckFile(fileName)
    WriteCheck fileName, fso.FileExists(basePath & "\" & fileName), basePath & "\" & fileName
End Sub

Sub ListCompanyFolders(root, outFileObj)
    Dim folder, subfolder, n
    n = 0
    If Not fso.FolderExists(root) Then Exit Sub
    Set folder = fso.GetFolder(root)
    For Each subfolder In folder.SubFolders
        If fso.FileExists(subfolder.Path & "\Personal.mdb") Then
            n = n + 1
            outFileObj.WriteLine n & ") " & subfolder.Name & " -> " & subfolder.Path
        End If
    Next
    If n = 0 Then outFileObj.WriteLine "No se detectaron carpetas con Personal.mdb."
End Sub

Sub DumpFile(path, outFileObj)
    Dim ts
    If Not fso.FileExists(path) Then
        outFileObj.WriteLine "NO EXISTE: " & path
        Exit Sub
    End If
    Set ts = fso.OpenTextFile(path, 1, False)
    If ts.AtEndOfStream Then outFileObj.WriteLine "(vacio)"
    Do Until ts.AtEndOfStream
        outFileObj.WriteLine ts.ReadLine
    Loop
    ts.Close
End Sub

Sub DumpQuery(dbObj, sql, outFileObj)
    Dim rs, i, line, v
    On Error Resume Next
    Set rs = dbObj.OpenRecordset(sql)
    If Err.Number <> 0 Then
        outFileObj.WriteLine "ERROR consulta: " & Err.Description & " SQL=" & sql
        Err.Clear
        On Error GoTo 0
        Exit Sub
    End If
    On Error GoTo 0
    If rs.EOF Then outFileObj.WriteLine "(sin registros)"
    Do Until rs.EOF
        line = ""
        For i = 0 To rs.Fields.Count - 1
            If IsNull(rs.Fields(i).Value) Then
                v = "NULL"
            Else
                v = CStr(rs.Fields(i).Value)
            End If
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
