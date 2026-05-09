@echo off
setlocal

set BASE=C:\GNS Software\GNS Personal PRO\Valor Humano
set RUNTIME_VBS=%TEMP%\verificar_limpieza_valor_humano_runtime.vbs
set CSCRIPT32=C:\Windows\SysWOW64\cscript.exe

echo Verificando limpieza de base Valor Humano...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "@'
Option Explicit

Dim fso, basePath, dbPath, outPath, dao, db, outFile
Dim limpiar, conservar, i, t, c, errores, pendientes, okMaestras

basePath = ""C:\GNS Software\GNS Personal PRO\Valor Humano""
dbPath = basePath & ""\Personal.mdb""
outPath = basePath & ""\verificacion_limpieza_valor_humano.txt""

Set fso = CreateObject(""Scripting.FileSystemObject"")
Set outFile = fso.CreateTextFile(outPath, True)
outFile.WriteLine ""VERIFICACION LIMPIEZA VALOR HUMANO""
outFile.WriteLine ""Fecha: "" & Now
outFile.WriteLine ""Base: "" & dbPath
outFile.WriteLine String(80, ""-"")

If Not fso.FileExists(dbPath) Then
    outFile.WriteLine ""ERROR: No existe Personal.mdb""
    outFile.Close
    WScript.Echo ""ERROR: No existe Personal.mdb""
    WScript.Quit 1
End If

On Error Resume Next
Set dao = CreateObject(""DAO.DBEngine.120"")
If Err.Number <> 0 Then
    outFile.WriteLine ""ERROR DAO: "" & Err.Description
    outFile.Close
    WScript.Echo ""ERROR DAO. Ver reporte.""
    WScript.Quit 1
End If
Set db = dao.OpenDatabase(dbPath)
If Err.Number <> 0 Then
    outFile.WriteLine ""ERROR abriendo base: "" & Err.Description
    outFile.Close
    WScript.Echo ""ERROR abriendo base. Ver reporte.""
    WScript.Quit 1
End If
On Error GoTo 0

limpiar = Array(""Personas"",""Contrato"",""Encabezados"",""Datos_Liquidacion"",""Datos_deAportes"",""Legajo"",""Licencias"",""PlanificDeLicencia"",""PagosEnSueldo"",""PagosEnSueldoDeta"",""MTSS"",""MTSSDeta"",""MTSSRem"",""Declaraciones"",""PersonasRela"",""rEmpleado_Documentos"",""rLic_Enc"",""ImagenEmp"",""WebContHabil"",""AuxContrato"")
conservar = Array(""Empresa"",""Conceptos"",""TiposLiquidacion"",""Bancos"",""Cargos"",""Sectores"",""Sucursales"",""Localidades"",""Paises"",""Monedas"",""Valores"",""Funciones"",""Documentos_Exigidos"")

pendientes = 0
errores = 0
okMaestras = 0

outFile.WriteLine ""TABLAS QUE DEBERIAN QUEDAR EN CERO""
outFile.WriteLine String(80, ""-"")
For i = 0 To UBound(limpiar)
    t = limpiar(i)
    c = CountTable(db, t)
    outFile.WriteLine PadRight(t, 30) & "" registros="" & c
    If IsNumeric(c) Then
        If CLng(c) > 0 Then pendientes = pendientes + 1
    Else
        errores = errores + 1
    End If
Next

outFile.WriteLine """"
outFile.WriteLine ""TABLAS MAESTRAS QUE DEBERIAN CONSERVAR DATOS""
outFile.WriteLine String(80, ""-"")
For i = 0 To UBound(conservar)
    t = conservar(i)
    c = CountTable(db, t)
    outFile.WriteLine PadRight(t, 30) & "" registros="" & c
    If IsNumeric(c) Then
        If CLng(c) > 0 Then okMaestras = okMaestras + 1
    Else
        errores = errores + 1
    End If
Next

outFile.WriteLine """"
outFile.WriteLine String(80, ""-"")
outFile.WriteLine ""RESUMEN""
outFile.WriteLine ""Tablas operativas con datos pendientes: "" & pendientes
outFile.WriteLine ""Tablas maestras con datos presentes: "" & okMaestras & "" de "" & (UBound(conservar)+1)
outFile.WriteLine ""Errores de lectura: "" & errores

If pendientes = 0 And errores = 0 Then
    outFile.WriteLine ""RESULTADO: LIMPIEZA OPERATIVA CORRECTA.""
Else
    outFile.WriteLine ""RESULTADO: REVISAR. Hay datos demo pendientes o errores.""
End If

db.Close
outFile.Close
WScript.Echo ""Verificacion generada en: "" & outPath

Function CountTable(dbObj, tableName)
    Dim rs, sql
    On Error Resume Next
    sql = ""SELECT COUNT(*) AS CANTIDAD FROM ["" & Replace(tableName, ""]"", ""]]"") & ""]""
    Set rs = dbObj.OpenRecordset(sql)
    If Err.Number <> 0 Then
        CountTable = ""ERROR: "" & Err.Description
        Err.Clear
    Else
        CountTable = CStr(rs.Fields(""CANTIDAD"").Value)
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
'@ | Set-Content -LiteralPath '%RUNTIME_VBS%' -Encoding ASCII"

"%CSCRIPT32%" //nologo "%RUNTIME_VBS%"

echo.
echo Abra y pegue en ChatGPT:
echo C:\GNS Software\GNS Personal PRO\Valor Humano\verificacion_limpieza_valor_humano.txt
echo.
pause
