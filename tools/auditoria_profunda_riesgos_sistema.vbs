' Auditoria profunda de riesgos operativos del Sistema de Gestion.
' NO modifica nada. No elimina ni altera controles. Solo lee y reporta.
'
' Revisa:
' 1) Senales de control por PC.
' 2) Habilitacion de empresa/usuario.
' 3) Parametros de validacion interna visibles.
' 4) Dependencias externas, OCX/DLL y utilitarios referenciados.

Option Explicit

Dim fso, shell, basePath, empPath, outPath, outFile, dao, dbU, dbP

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
outPath = basePath & "\auditoria_profunda_riesgos_sistema.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "AUDITORIA PROFUNDA DE RIESGOS - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine "Base: " & basePath
outFile.WriteLine String(100, "-")
outFile.WriteLine "Este reporte NO modifica nada. Solo detecta dependencias, configuraciones y riesgos operativos visibles."
outFile.WriteLine "No intenta remover, alterar ni saltar validaciones/licencias."
outFile.WriteLine ""

outFile.WriteLine "1) CONTROL POR PC / EQUIPO"
outFile.WriteLine String(100, "-")
outFile.WriteLine "Claves de registro que pueden indicar configuracion atada a PC:"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\CodPC"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\VersionFechaDeCreada"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\PathAplicacion"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGral"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGralLstEmp"
ReadReg "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\CodPC"
ReadReg "HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\VersionFechaDeCreada"
outFile.WriteLine ""
outFile.WriteLine "Secciones ConfiguraSis.ini relacionadas a equipo/codigo:"
PrintSection basePath & "\ConfiguraSis.ini", "ValidacionLicencia"
PrintSection basePath & "\ConfiguraSis.ini", "CodigoSistema"
PrintSection basePath & "\ConfiguraSis.ini", "ListaPC"
outFile.WriteLine ""

outFile.WriteLine "2) EMPRESA HABILITADA / USUARIO HABILITADO"
outFile.WriteLine String(100, "-")
outFile.WriteLine "ListEmpresas.ini:"
DumpFile basePath & "\ListEmpresas.ini"
outFile.WriteLine ""
outFile.WriteLine "ListEmpresas sin extension:"
DumpFile basePath & "\ListEmpresas"
outFile.WriteLine ""
outFile.WriteLine "Archivo CodEmp de carpeta Valor Humano, si existe:"
DumpFile empPath & "\CodEmp"
outFile.WriteLine ""

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR creando DAO.DBEngine.120: " & Err.Description
    outFile.WriteLine "No se pudieron inspeccionar bases MDB."
    outFile.Close
    WScript.Echo "Auditoria generada con error DAO. Ver: " & outPath
    WScript.Quit 0
End If
On Error GoTo 0

If fso.FileExists(basePath & "\Usuarios.mdb") Then
    On Error Resume Next
    Set dbU = dao.OpenDatabase(basePath & "\Usuarios.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Usuarios.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "Usuarios.mdb - conteos:"
        WriteCount dbU, "Usuarios"
        WriteCount dbU, "EmpHabil"
        WriteCount dbU, "EstEmp"
        WriteCount dbU, "Permisos"
        outFile.WriteLine ""
        outFile.WriteLine "Usuarios.mdb - Usuarios:"
        DumpQuery dbU, "SELECT * FROM Usuarios", outFile
        outFile.WriteLine ""
        outFile.WriteLine "Usuarios.mdb - EmpHabil:"
        DumpQuery dbU, "SELECT * FROM EmpHabil", outFile
        outFile.WriteLine ""
        outFile.WriteLine "Usuarios.mdb - EstEmp:"
        DumpQuery dbU, "SELECT * FROM EstEmp", outFile
        outFile.WriteLine ""
        outFile.WriteLine "Usuarios.mdb - Registro:"
        DumpQuery dbU, "SELECT * FROM Registro", outFile
        dbU.Close
    End If
    On Error GoTo 0
Else
    outFile.WriteLine "No existe Usuarios.mdb"
End If
outFile.WriteLine ""

outFile.WriteLine "3) VALIDACION INTERNA VISIBLE / CONFIGURACION HEREDADA"
outFile.WriteLine String(100, "-")
outFile.WriteLine "Lineas relevantes en ConfiguraSis.ini y Configura.ini:"
FindInText basePath & "\ConfiguraSis.ini", Array("ValidacionLicencia", "CodigoSistema", "ListaPC", "CheqVersAlInicio", "UsarHTTPS", "Modulo Web", "Importador", "personal.mdb", "IDUSU", "PASS")
FindInText basePath & "\Configura.ini", Array("ValidacionLicencia", "CodigoSistema", "ListaPC", "CheqVersAlInicio", "Modulo Web", "Importador", "personal.mdb", "IDUSU", "PASS", "GnsTmp", "Update")
outFile.WriteLine ""

outFile.WriteLine "4) DEPENDENCIAS EXTERNAS Y UTILITARIOS"
outFile.WriteLine String(100, "-")
outFile.WriteLine "OCX/DLL principales presentes:"
CheckFile "BtnDibu4.ocx"
CheckFile "OtrosObjZinco.ocx"
CheckFile "ZincoGrid.ocx"
CheckFile "PaComunicar.ocx"
CheckFile "ControlParaRep.ocx"
CheckFile "crviewer9.dll"
CheckFile "DllConexion.dll"
CheckFile "DllConexion4.dll"
CheckFile "LibGeneral.dll"
CheckFile "LibGeneral4.dll"
CheckFile "FuncionesVarias.dll"
CheckFile "FuncionesVarias4.dll"
CheckFile "msadodc.ocx"
CheckFile "comdlg32.ocx"
CheckFile "mscomct2.ocx"
CheckFile "tabctl32.ocx"
CheckFile "msflxgrd.ocx"
outFile.WriteLine ""
outFile.WriteLine "Utilitarios referenciados por ConfiguraSis.ini / Configura.ini:"
CheckReferencedUtil "Utiles\ImportaHoras.exe"
CheckReferencedUtil "Utiles\IG\ImportadorGeneral.exe"
CheckReferencedUtil "Utiles\DatosWeb\ModuloWeb.exe"
CheckReferencedUtil "Utiles\ImportarDatos.exe"
CheckReferencedUtil "Utiles\gennum.jar"
CheckReferencedUtil "Utiles\CajaBancaria\Caja Bancaria.exe"
CheckReferencedUtil "Utiles\AbitabRecibos.exe"
outFile.WriteLine ""

outFile.WriteLine "5) BASE EMPRESA - DATOS Y CONTEOS"
outFile.WriteLine String(100, "-")
If fso.FileExists(empPath & "\Personal.mdb") Then
    On Error Resume Next
    Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
    If Err.Number <> 0 Then
        outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
        Err.Clear
    Else
        outFile.WriteLine "Conteos operativos:"
        WriteCount dbP, "Personas"
        WriteCount dbP, "Contrato"
        WriteCount dbP, "Legajo"
        WriteCount dbP, "Encabezados"
        WriteCount dbP, "Datos_Liquidacion"
        WriteCount dbP, "Licencias"
        WriteCount dbP, "MTSS"
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

outFile.WriteLine "6) LECTURA ORIENTATIVA"
outFile.WriteLine String(100, "-")
outFile.WriteLine "Control por PC: si aparecen CodPC, ListaPC o CodigoSistema, hay senales de configuracion atada al equipo o validacion heredada."
outFile.WriteLine "Empresa habilitada: EmpHabil y EstEmp indican que el usuario/empresa se controla desde Usuarios.mdb."
outFile.WriteLine "Validacion interna: ConfiguraSis.ini contiene parametros visibles; si el sistema abre y guarda datos, no hay bloqueo actual evidente."
outFile.WriteLine "Dependencias: cualquier utilitario o OCX/DLL faltante puede afectar modulos puntuales aunque el sistema principal abra."
outFile.WriteLine "No se deben alterar controles de licencia; esta auditoria es solo operativa y preventiva."
outFile.WriteLine ""
outFile.WriteLine "FIN"
outFile.Close

WScript.Echo "Auditoria profunda generada en: " & outPath

Sub CheckFile(fileName)
    Dim p
    p = basePath & "\" & fileName
    If fso.FileExists(p) Then outFile.WriteLine "OK - " & fileName Else outFile.WriteLine "FALTA - " & fileName
End Sub

Sub CheckReferencedUtil(relPath)
    Dim p
    p = basePath & "\" & relPath
    If fso.FileExists(p) Then outFile.WriteLine "OK - " & relPath Else outFile.WriteLine "FALTA - " & relPath
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

Sub PrintSection(filePath, sectionName)
    Dim ts, line, inside
    If Not fso.FileExists(filePath) Then
        outFile.WriteLine "No existe: " & filePath
        Exit Sub
    End If
    outFile.WriteLine "[" & sectionName & "] en " & filePath & ":"
    Set ts = fso.OpenTextFile(filePath, 1, False)
    inside = False
    Do Until ts.AtEndOfStream
        line = ts.ReadLine
        If Trim(line) = "[" & sectionName & "]" Then
            inside = True
            outFile.WriteLine line
        ElseIf Trim(line) = "[/" & sectionName & "]" Then
            outFile.WriteLine line
            inside = False
        ElseIf inside Then
            outFile.WriteLine line
        End If
    Loop
    ts.Close
End Sub

Sub DumpFile(path)
    Dim ts
    If Not fso.FileExists(path) Then
        outFile.WriteLine "NO EXISTE: " & path
        Exit Sub
    End If
    Set ts = fso.OpenTextFile(path, 1, False)
    If ts.AtEndOfStream Then outFile.WriteLine "(vacio)"
    Do Until ts.AtEndOfStream
        outFile.WriteLine ts.ReadLine
    Loop
    ts.Close
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
