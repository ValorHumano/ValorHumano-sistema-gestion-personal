' Auditoria de dependencias OCX/DLL para Sistema de Gestion.
' NO modifica nada. Solo verifica si archivos existen en carpeta local, SysWOW64 y System32.

Option Explicit

Dim fso, shell, basePath, outPath, outFile, deps, i

basePath = "C:\GNS Software\GNS Personal PRO"
outPath = basePath & "\auditoria_dependencias_ocx_sistema_gestion.txt"
deps = Array( _
"msadodc.ocx", _
"comdlg32.ocx", _
"mscomct2.ocx", _
"tabctl32.ocx", _
"msflxgrd.ocx", _
"BtnDibu4.ocx", _
"OtrosObjZinco.ocx", _
"ZincoGrid.ocx", _
"PaComunicar.ocx", _
"ControlParaRep.ocx", _
"crviewer9.dll", _
"DllConexion.dll", _
"DllConexion4.dll", _
"LibGeneral.dll", _
"LibGeneral4.dll", _
"FuncionesVarias.dll", _
"FuncionesVarias4.dll" _
)

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set outFile = fso.CreateTextFile(outPath, True)

outFile.WriteLine "AUDITORIA DEPENDENCIAS OCX/DLL - SISTEMA DE GESTION"
outFile.WriteLine "Fecha: " & Now
outFile.WriteLine String(90, "-")
outFile.WriteLine "Este reporte NO modifica nada. Solo verifica presencia de componentes."
outFile.WriteLine ""

outFile.WriteLine "1) ARCHIVOS EN CARPETA DEL SISTEMA / WINDOWS"
outFile.WriteLine String(90, "-")
For i = 0 To UBound(deps)
    CheckDependency CStr(deps(i))
Next
outFile.WriteLine ""

outFile.WriteLine "2) UTILITARIOS REFERENCIADOS"
outFile.WriteLine String(90, "-")
CheckPath "Utiles\ImportaHoras.exe"
CheckPath "Utiles\ImportadorDeHL.exe"
CheckPath "Utiles\IG\ImportadorGeneral.exe"
CheckPath "Utiles\DatosWeb\ModuloWeb.exe"
CheckPath "Utiles\ImportarDatos.exe"
CheckPath "Utiles\gennum.jar"
CheckPath "Utiles\CajaBancaria\Caja Bancaria.exe"
CheckPath "Utiles\AbitabRecibos.exe"
outFile.WriteLine ""

outFile.WriteLine "3) LECTURA ORIENTATIVA"
outFile.WriteLine String(90, "-")
outFile.WriteLine "Si una dependencia falta en la carpeta local pero existe en SysWOW64/System32, el sistema puede funcionar en esta PC."
outFile.WriteLine "Para instalar en otra PC, conviene incluir o registrar las dependencias necesarias."
outFile.WriteLine "Si faltan utilitarios como Caja Bancaria o AbitabRecibos, solo fallaran esos modulos puntuales si se usan."
outFile.WriteLine "FIN"
outFile.Close

MsgBox "Auditoria de dependencias generada en: " & outPath, 64, "Sistema de Gestion"

Sub CheckDependency(fileName)
    Dim pLocal, pSysWow, pSystem32, status
    pLocal = basePath & "\" & fileName
    pSysWow = "C:\Windows\SysWOW64\" & fileName
    pSystem32 = "C:\Windows\System32\" & fileName
    status = ""
    If fso.FileExists(pLocal) Then status = status & "LOCAL "
    If fso.FileExists(pSysWow) Then status = status & "SYSWOW64 "
    If fso.FileExists(pSystem32) Then status = status & "SYSTEM32 "
    If status = "" Then status = "FALTA"
    outFile.WriteLine fileName & " = " & status
End Sub

Sub CheckPath(relPath)
    Dim p
    p = basePath & "\" & relPath
    If fso.FileExists(p) Then
        outFile.WriteLine "OK - " & relPath
    Else
        outFile.WriteLine "FALTA - " & relPath
    End If
End Sub
