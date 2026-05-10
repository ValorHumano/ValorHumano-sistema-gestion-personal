' Verificador post-instalacion Sistema de Gestion.
' NO modifica nada. Se puede ejecutar en la PC nueva luego de instalar.

Option Explicit

Dim fso, shell, basePath, empPath, outPath, outFile, dao, dbU, dbP

basePath = "C:\GNS Software\GNS Personal PRO"
empPath = basePath & "\Valor Humano"
outPath = basePath & "\verificacion_post_instalacion_sistema_gestion.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "VERIFICACION POST-INSTALACION - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")

outFile.WriteLine "1) ARCHIVOS CRITICOS"
outFile.WriteLine String(90, "-")
CheckFile "SistemaGestion.exe", basePath & "\SistemaGestion.exe"
CheckFile "Usuarios.mdb", basePath & "\Usuarios.mdb"
CheckFile "Configura.ini", basePath & "\Configura.ini"
CheckFile "ConfiguraSis.ini", basePath & "\ConfiguraSis.ini"
CheckFile "ListEmpresas.ini", basePath & "\ListEmpresas.ini"
CheckFile "ListEmpresas", basePath & "\ListEmpresas"
CheckFile "Valor Humano\Personal.mdb", empPath & "\Personal.mdb"
CheckFolder "Generica", basePath & "\Generica"
CheckFolder "Valor Humano\Respaldos", empPath & "\Respaldos"
CheckFolder "Valor Humano\HistorialLaboral", empPath & "\HistorialLaboral"
CheckFolder "Valor Humano\imgEmpleados", empPath & "\imgEmpleados"
CheckFolder "Valor Humano\MTSS", empPath & "\MTSS"
CheckFolder "Valor Humano\Reportes", empPath & "\Reportes"
outFile.WriteLine ""

outFile.WriteLine "2) REGISTRO"
outFile.WriteLine String(90, "-")
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\PathAplicacion"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGral"
ReadReg "HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal\BaseGralLstEmp"
outFile.WriteLine ""

outFile.WriteLine "3) DEPENDENCIAS"
outFile.WriteLine String(90, "-")
CheckDep "BtnDibu4.ocx"
CheckDep "OtrosObjZinco.ocx"
CheckDep "ZincoGrid.ocx"
CheckDep "PaComunicar.ocx"
CheckDep "ControlParaRep.ocx"
CheckDep "crviewer9.dll"
CheckDep "DllConexion.dll"
CheckDep "DllConexion4.dll"
CheckDep "LibGeneral.dll"
CheckDep "LibGeneral4.dll"
CheckDep "FuncionesVarias.dll"
CheckDep "FuncionesVarias4.dll"
CheckDep "msadodc.ocx"
CheckDep "comdlg32.ocx"
CheckDep "mscomct2.ocx"
CheckDep "tabctl32.ocx"
CheckDep "msflxgrd.ocx"
outFile.WriteLine ""

On Error Resume Next
Set dao = CreateObject("DAO.DBEngine.120")
If Err.Number <> 0 Then
    outFile.WriteLine "ERROR DAO.DBEngine.120: " & Err.Description
    outFile.WriteLine "No se pudo abrir motor Access/DAO."
    Err.Clear
Else
    On Error GoTo 0
    outFile.WriteLine "4) BASE GENERAL"
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
            dbU.Close
        End If
        On Error GoTo 0
    Else
        outFile.WriteLine "FALTA Usuarios.mdb"
    End If
    outFile.WriteLine ""

    outFile.WriteLine "5) BASE EMPRESA"
    outFile.WriteLine String(90, "-")
    If fso.FileExists(empPath & "\Personal.mdb") Then
        On Error Resume Next
        Set dbP = dao.OpenDatabase(empPath & "\Personal.mdb")
        If Err.Number <> 0 Then
            outFile.WriteLine "ERROR abriendo Personal.mdb: " & Err.Description
            Err.Clear
        Else
            WriteCount dbP, "Personas"
            WriteCount dbP, "Contrato"
            WriteCount dbP, "Legajo"
            WriteCount dbP, "Encabezados"
            WriteCount dbP, "Datos_Liquidacion"
            WriteCount dbP, "Conceptos"
            WriteCount dbP, "Valores"
            dbP.Close
        End If
        On Error GoTo 0
    Else
        outFile.WriteLine "FALTA Valor Humano\Personal.mdb"
    End If
End If

outFile.WriteLine ""
outFile.WriteLine "6) RESULTADO"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Si los archivos criticos estan OK, abra desde el escritorio: Sistema de Gestion."
outFile.WriteLine "Prueba minima: login, abrir empresa, crear empleado de prueba, crear contrato, generar liquidacion simple."
outFile.WriteLine "FIN"
outFile.Close

MsgBox "Verificacion generada en: " & outPath, 64, "Sistema de Gestion"

Sub CheckFile(label, path)
    If fso.FileExists(path) Then outFile.WriteLine "OK - " & label Else outFile.WriteLine "FALTA - " & label & " -> " & path
End Sub

Sub CheckFolder(label, path)
    If fso.FolderExists(path) Then outFile.WriteLine "OK - " & label Else outFile.WriteLine "FALTA - " & label & " -> " & path
End Sub

Sub CheckDep(fileName)
    Dim status
    status = ""
    If fso.FileExists(basePath & "\" & fileName) Then status = status & "LOCAL "
    If fso.FileExists("C:\Windows\SysWOW64\" & fileName) Then status = status & "SYSWOW64 "
    If fso.FileExists("C:\Windows\System32\" & fileName) Then status = status & "SYSTEM32 "
    If status = "" Then status = "FALTA"
    outFile.WriteLine fileName & " = " & status
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
