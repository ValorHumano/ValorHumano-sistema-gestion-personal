$ErrorActionPreference = 'SilentlyContinue'

# DIAGNOSTICO AVANZADO INTEGRAL - SISTEMA DE GESTION
# Solo lectura, salvo la creacion del reporte y archivos temporales de prueba de escritura.
# No modifica bases, usuarios, licencias, claves, liquidaciones ni configuracion operativa.

$Base = 'C:\GNS Software\GNS Personal PRO'
$Emp = Join-Path $Base 'Valor Humano'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$OutTxt = Join-Path $Base "diagnostico_avanzado_integral_$Stamp.txt"
$OutHtml = Join-Path $Base "diagnostico_avanzado_integral_$Stamp.html"
$Results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param(
        [string]$Area,
        [string]$Check,
        [string]$Status,
        [string]$Detail,
        [string]$Recommendation = ''
    )
    $Results.Add([pscustomobject]@{
        Area = $Area
        Check = $Check
        Status = $Status
        Detail = $Detail
        Recommendation = $Recommendation
    }) | Out-Null
}

function Test-PathFile {
    param([string]$Area, [string]$Label, [string]$Path, [bool]$Critical = $true)
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $item = Get-Item -LiteralPath $Path
        Add-Result $Area $Label 'OK' ("$Path | $($item.Length) bytes | modificado $($item.LastWriteTime)") ''
    } else {
        Add-Result $Area $Label ($(if($Critical){'FAIL'}else{'WARN'})) "Falta archivo: $Path" 'Copiar desde la instalacion funcional o paquete original.'
    }
}

function Test-PathFolder {
    param([string]$Area, [string]$Label, [string]$Path, [bool]$Critical = $true)
    if (Test-Path -LiteralPath $Path -PathType Container) {
        Add-Result $Area $Label 'OK' $Path ''
    } else {
        Add-Result $Area $Label ($(if($Critical){'FAIL'}else{'WARN'})) "Falta carpeta: $Path" 'Crear carpeta o restaurar desde respaldo.'
    }
}

function Test-WriteAccess {
    param([string]$Area, [string]$Label, [string]$Folder)
    try {
        if (!(Test-Path -LiteralPath $Folder -PathType Container)) {
            Add-Result $Area $Label 'FAIL' "No existe carpeta para probar escritura: $Folder" 'Crear carpeta.'
            return
        }
        $tmp = Join-Path $Folder ("_test_write_" + [guid]::NewGuid().ToString('N') + '.tmp')
        'test' | Set-Content -LiteralPath $tmp -Encoding ASCII
        Remove-Item -LiteralPath $tmp -Force
        Add-Result $Area $Label 'OK' "Escritura OK en $Folder" ''
    } catch {
        Add-Result $Area $Label 'FAIL' "Sin escritura en $Folder | $($_.Exception.Message)" 'Revisar permisos o ejecutar como administrador.'
    }
}

function Read-RegValue {
    param([string]$Area, [string]$Name, [string]$Key, [string]$ValueName, [string]$Expected = '')
    try {
        $v = (Get-ItemProperty -Path $Key -Name $ValueName -ErrorAction Stop).$ValueName
        if ($Expected -and ($v -ne $Expected)) {
            Add-Result $Area $Name 'WARN' "$Key\$ValueName = $v | esperado: $Expected" 'Corregir ruta de registro si el sistema falla.'
        } else {
            Add-Result $Area $Name 'OK' "$Key\$ValueName = $v" ''
        }
    } catch {
        Add-Result $Area $Name 'WARN' "No encontrado: $Key\$ValueName" 'Puede requerirse reparar registro si falla apertura.'
    }
}

function Test-Component {
    param([string]$File)
    $paths = @(
        (Join-Path $Base $File),
        (Join-Path 'C:\Windows\SysWOW64' $File),
        (Join-Path 'C:\Windows\System32' $File),
        (Join-Path 'C:\Windows\SysWOW64\Redist\MS\System' $File)
    )
    $found = @()
    foreach ($p in $paths) {
        if (Test-Path -LiteralPath $p -PathType Leaf) { $found += $p }
    }
    if ($found.Count -eq 0) {
        Add-Result 'Componentes' $File 'FAIL' 'No encontrado en carpeta local, SysWOW64, System32 ni Redist.' 'Conseguir componente legitimo y registrar.'
    } elseif ($found[0] -like "$Base*") {
        Add-Result 'Componentes' $File 'OK' ($found -join ' | ') ''
    } else {
        Add-Result 'Componentes' $File 'WARN' ($found -join ' | ') 'Existe en Windows, pero conviene copiarlo al paquete local si lo usa algun modulo.'
    }
}

function Test-DaoDatabase {
    param([string]$Area, [string]$Label, [string]$Path, [string[]]$Tables)
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-Result $Area $Label 'FAIL' "No existe base: $Path" 'Restaurar base.'
        return
    }
    try {
        $dao = New-Object -ComObject DAO.DBEngine.120
        $db = $dao.OpenDatabase($Path)
        Add-Result $Area "$Label apertura" 'OK' "Base abre correctamente: $Path" ''
        foreach ($t in $Tables) {
            try {
                $rs = $db.OpenRecordset("SELECT COUNT(*) AS C FROM [$t]")
                $count = $rs.Fields.Item('C').Value
                Add-Result $Area "Tabla $t" 'OK' "$count registros" ''
                $rs.Close()
            } catch {
                Add-Result $Area "Tabla $t" 'WARN' "No se pudo contar: $($_.Exception.Message)" 'Puede ser tabla inexistente o nombre distinto.'
            }
        }
        $db.Close()
    } catch {
        Add-Result $Area $Label 'FAIL' "No abre con DAO: $($_.Exception.Message)" 'Revisar motor Access/DAO o base bloqueada/corrupta.'
    }
}

function Test-IniLine {
    param([string]$Area, [string]$Label, [string]$Path, [string]$MustContain)
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-Result $Area $Label 'FAIL' "No existe: $Path" 'Restaurar archivo.'
        return
    }
    $txt = Get-Content -LiteralPath $Path -Raw
    if ($txt -like "*$MustContain*") {
        Add-Result $Area $Label 'OK' "Contiene: $MustContain" ''
    } else {
        Add-Result $Area $Label 'WARN' "No contiene: $MustContain" 'Revisar configuracion si falla modulo relacionado.'
    }
}

function Test-ExternalUtility {
    param([string]$RelPath, [bool]$Critical = $false)
    $p = Join-Path $Base $RelPath
    if (Test-Path -LiteralPath $p -PathType Leaf) {
        $item = Get-Item -LiteralPath $p
        Add-Result 'Utilitarios externos' $RelPath 'OK' "$p | $($item.Length) bytes" ''
    } else {
        Add-Result 'Utilitarios externos' $RelPath ($(if($Critical){'FAIL'}else{'WARN'})) "Falta: $p" 'Si no se usa este modulo, no es critico. Si se usa, copiar desde paquete original.'
    }
}

function Test-ProcessLaunch {
    $exe = Join-Path $Base 'SistemaGestion.exe'
    if (!(Test-Path -LiteralPath $exe -PathType Leaf)) {
        Add-Result 'Smoke test' 'Lanzamiento SistemaGestion.exe' 'FAIL' "No existe $exe" 'Restaurar ejecutable.'
        return
    }
    try {
        $p = Start-Process -FilePath $exe -WorkingDirectory $Base -PassThru
        Start-Sleep -Seconds 5
        $proc = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
        if ($proc) {
            $title = $proc.MainWindowTitle
            Add-Result 'Smoke test' 'Lanzamiento SistemaGestion.exe' 'OK' "Proceso iniciado. PID=$($p.Id). Titulo='$title'" 'Cerrar manualmente si quedo abierto.'
        } else {
            Add-Result 'Smoke test' 'Lanzamiento SistemaGestion.exe' 'WARN' 'El proceso cerro durante los primeros 5 segundos.' 'Revisar si hubo mensaje de error visible.'
        }
    } catch {
        Add-Result 'Smoke test' 'Lanzamiento SistemaGestion.exe' 'FAIL' "No pudo iniciar: $($_.Exception.Message)" 'Revisar dependencias o permisos.'
    }
}

# Inicio
if (!(Test-Path -LiteralPath $Base -PathType Container)) {
    New-Item -Path $Base -ItemType Directory -Force | Out-Null
}

Add-Result 'Entorno' 'Usuario Windows' 'OK' ([Environment]::UserName) ''
Add-Result 'Entorno' 'Equipo' 'OK' ([Environment]::MachineName) ''
Add-Result 'Entorno' 'Sistema operativo' 'OK' ((Get-CimInstance Win32_OperatingSystem).Caption + ' ' + (Get-CimInstance Win32_OperatingSystem).OSArchitecture) ''
Add-Result 'Entorno' 'PowerShell' 'OK' $PSVersionTable.PSVersion.ToString() ''

# Archivos criticos
Test-PathFile 'Archivos criticos' 'SistemaGestion.exe' (Join-Path $Base 'SistemaGestion.exe') $true
Test-PathFile 'Archivos criticos' 'Usuarios.mdb' (Join-Path $Base 'Usuarios.mdb') $true
Test-PathFile 'Archivos criticos' 'Personal.mdb empresa' (Join-Path $Emp 'Personal.mdb') $true
Test-PathFile 'Archivos criticos' 'Configura.ini' (Join-Path $Base 'Configura.ini') $true
Test-PathFile 'Archivos criticos' 'ConfiguraSis.ini' (Join-Path $Base 'ConfiguraSis.ini') $true
Test-PathFile 'Archivos criticos' 'ListEmpresas' (Join-Path $Base 'ListEmpresas') $true
Test-PathFile 'Archivos criticos' 'ListEmpresas.ini' (Join-Path $Base 'ListEmpresas.ini') $false

# Carpetas
foreach ($f in @($Base,$Emp,(Join-Path $Emp 'Respaldos'),(Join-Path $Emp 'HistorialLaboral'),(Join-Path $Emp 'HistoriaLaboral'),(Join-Path $Emp 'imgEmpleados'),(Join-Path $Emp 'MTSS'),(Join-Path $Emp 'Reportes'),'C:\GnsTmp','C:\MTSS - GNS','C:\BPS - GNS','C:\FOCER - GNS')) {
    Test-PathFolder 'Carpetas' $f $f $false
}
Test-WriteAccess 'Permisos' 'Escritura carpeta empresa' $Emp
Test-WriteAccess 'Permisos' 'Escritura respaldos' (Join-Path $Emp 'Respaldos')
Test-WriteAccess 'Permisos' 'Escritura temporal C:\GnsTmp' 'C:\GnsTmp'

# Registro
$reg = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal'
Read-RegValue 'Registro' 'PathAplicacion' $reg 'PathAplicacion' ($Base + '\')
Read-RegValue 'Registro' 'BaseGral' $reg 'BaseGral' ($Base + '\')
Read-RegValue 'Registro' 'BaseGralLstEmp' $reg 'BaseGralLstEmp' ($Base + '\')
Read-RegValue 'Registro' 'CodPC' $reg 'CodPC' ''
Read-RegValue 'Registro' 'VersionFechaDeCreada' $reg 'VersionFechaDeCreada' ''

# Configuracion
Test-IniLine 'Configuracion' 'ListEmpresas apunta a Valor Humano' (Join-Path $Base 'ListEmpresas') 'Valor Humano'
Test-IniLine 'Configuracion' 'ConfiguraSis ValidacionLicencia presente' (Join-Path $Base 'ConfiguraSis.ini') '[ValidacionLicencia]'
Test-IniLine 'Configuracion' 'ConfiguraSis ListaPC presente' (Join-Path $Base 'ConfiguraSis.ini') '[ListaPC]'
Test-IniLine 'Configuracion' 'Configura importador Excel' (Join-Path $Base 'Configura.ini') 'Importar desde Excel'

# Bases
Test-DaoDatabase 'Base general' 'Usuarios.mdb' (Join-Path $Base 'Usuarios.mdb') @('Usuarios','EmpHabil','EstEmp','Permisos','Registro')
Test-DaoDatabase 'Base empresa' 'Personal.mdb' (Join-Path $Emp 'Personal.mdb') @('Empresa','Personas','Contrato','Legajo','Encabezados','Datos_Liquidacion','Licencias','Conceptos','Valores','Cargos','Sectores','Sucursales')

# Locks
foreach ($lock in @((Join-Path $Base 'Usuarios.ldb'),(Join-Path $Emp 'Personal.ldb'))) {
    if (Test-Path -LiteralPath $lock -PathType Leaf) {
        Add-Result 'Bloqueos MDB' (Split-Path $lock -Leaf) 'WARN' "Existe archivo de bloqueo: $lock" 'Cerrar sistema antes de respaldar, compactar o copiar bases.'
    } else {
        Add-Result 'Bloqueos MDB' (Split-Path $lock -Leaf) 'OK' 'No existe lock.' ''
    }
}

# Componentes
$components = @('msadodc.ocx','comdlg32.ocx','mscomct2.ocx','msflxgrd.ocx','tabctl32.ocx','vbalProgBar6.ocx','vbalIml6.ocx','vbaListView6.ocx','vbalTreeView6.ocx','ssdw3bo.ocx','AniGIF.ocx','CuadradoColores.ocx','BtnDibu4.ocx','OtrosObjZinco.ocx','ZincoGrid.ocx','PaComunicar.ocx','ControlParaRep.ocx','cPopMenuZinco.ocx','mswinsck.ocx','MsComCtl.ocx','crviewer9.dll','CRViewer.dll','XceedZip.dll','DllConexion.dll','DllConexion4.dll','LibGeneral.dll','LibGeneral4.dll','FuncionesVarias.dll','FuncionesVarias4.dll','ArchivosFormateados4.dll','ArchivosFormateadosPRO.dll','VB6STKIT.DLL')
foreach ($c in $components) { Test-Component $c }

# Utilitarios
Test-ExternalUtility 'Utiles\ImportaHoras.exe' $false
Test-ExternalUtility 'Utiles\ImportadorDeHL.exe' $false
Test-ExternalUtility 'Utiles\IG\ImportadorGeneral.exe' $false
Test-ExternalUtility 'Utiles\DatosWeb\ModuloWeb.exe' $false
Test-ExternalUtility 'Utiles\ImportarDatos.exe' $false
Test-ExternalUtility 'Utiles\gennum.jar' $false
Test-ExternalUtility 'Utiles\CajaBancaria\Caja Bancaria.exe' $false
Test-ExternalUtility 'Utiles\AbitabRecibos.exe' $false
Test-ExternalUtility 'Proyecciones.exe' $false

# Paquete instalador
$pkgZip1 = 'C:\SistemaGestion_Instalador\SistemaGestion_Paquete.zip'
$pkgZip2 = Join-Path ([Environment]::GetFolderPath('Desktop')) 'sistema de gestion completo\SistemaGestion_Instalador\SistemaGestion_Paquete.zip'
Test-PathFile 'Paquete instalador' 'ZIP C:\SistemaGestion_Instalador' $pkgZip1 $false
Test-PathFile 'Paquete instalador' 'ZIP Escritorio' $pkgZip2 $false

# Smoke launch optional: only if environment variable RUN_SMOKE_LAUNCH=1
if ($env:RUN_SMOKE_LAUNCH -eq '1') {
    Test-ProcessLaunch
} else {
    Add-Result 'Smoke test' 'Lanzamiento automatico' 'INFO' 'Omitido. Para ejecutarlo: set RUN_SMOKE_LAUNCH=1 antes del BAT.' ''
}

# Summary
$fail = ($Results | Where-Object {$_.Status -eq 'FAIL'}).Count
$warn = ($Results | Where-Object {$_.Status -eq 'WARN'}).Count
$ok = ($Results | Where-Object {$_.Status -eq 'OK'}).Count
$info = ($Results | Where-Object {$_.Status -eq 'INFO'}).Count

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('DIAGNOSTICO AVANZADO INTEGRAL - SISTEMA DE GESTION')
$lines.Add('Fecha: ' + (Get-Date))
$lines.Add('Base: ' + $Base)
$lines.Add(('Resumen: OK={0} WARN={1} FAIL={2} INFO={3}' -f $ok,$warn,$fail,$info))
$lines.Add((''.PadLeft(110,'-')))
foreach ($r in $Results) {
    $lines.Add(('[{0}] {1} | {2} | {3} | {4}' -f $r.Status, $r.Area, $r.Check, $r.Detail, $r.Recommendation))
}
$lines.Add((''.PadLeft(110,'-')))
$lines.Add('FIN')
$lines | Set-Content -LiteralPath $OutTxt -Encoding UTF8

$htmlRows = $Results | ForEach-Object {
    $color = switch ($_.Status) { 'OK' {'#d8f5d0'} 'WARN' {'#fff4c2'} 'FAIL' {'#ffd0d0'} 'INFO' {'#d9eaff'} default {'#ffffff'} }
    '<tr style="background:' + $color + '"><td>' + [System.Web.HttpUtility]::HtmlEncode($_.Status) + '</td><td>' + [System.Web.HttpUtility]::HtmlEncode($_.Area) + '</td><td>' + [System.Web.HttpUtility]::HtmlEncode($_.Check) + '</td><td>' + [System.Web.HttpUtility]::HtmlEncode($_.Detail) + '</td><td>' + [System.Web.HttpUtility]::HtmlEncode($_.Recommendation) + '</td></tr>'
}
Add-Type -AssemblyName System.Web
$html = @"
<html><head><meta charset="utf-8"><title>Diagnostico Sistema de Gestion</title>
<style>body{font-family:Segoe UI,Arial,sans-serif;font-size:13px} table{border-collapse:collapse;width:100%} td,th{border:1px solid #aaa;padding:5px;vertical-align:top} th{background:#333;color:white} .summary{font-size:18px;font-weight:bold;margin:12px 0}</style>
</head><body>
<h1>Diagnostico avanzado integral - Sistema de Gestion</h1>
<div class="summary">OK=$ok | WARN=$warn | FAIL=$fail | INFO=$info</div>
<p>Base: $Base<br>Fecha: $(Get-Date)</p>
<table><tr><th>Estado</th><th>Area</th><th>Chequeo</th><th>Detalle</th><th>Recomendacion</th></tr>
$($htmlRows -join "`n")
</table></body></html>
"@
$html | Set-Content -LiteralPath $OutHtml -Encoding UTF8

Write-Host 'Diagnostico generado:'
Write-Host $OutTxt
Write-Host $OutHtml
Write-Host ('Resumen: OK={0} WARN={1} FAIL={2} INFO={3}' -f $ok,$warn,$fail,$info)
