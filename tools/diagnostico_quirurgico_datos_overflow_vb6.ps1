$ErrorActionPreference = 'SilentlyContinue'

# DIAGNOSTICO QUIRURGICO DE DATOS / OVERFLOW VB6
# Solo lectura: no modifica bases ni configuracion.
# Objetivo: encontrar datos que puedan provocar Error 6 Desbordamiento u otros fallos al abrir pantallas.

$Base = 'C:\GNS Software\GNS Personal PRO'
$Emp = Join-Path $Base 'Valor Humano'
$DbEmpresa = Join-Path $Emp 'Personal.mdb'
$DbUsuarios = Join-Path $Base 'Usuarios.mdb'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Out = Join-Path $Base "diagnostico_quirurgico_datos_overflow_$Stamp.txt"
$Csv = Join-Path $Base "diagnostico_quirurgico_datos_overflow_$Stamp.csv"
$Findings = New-Object System.Collections.Generic.List[object]

function Add-Finding {
    param([string]$Level,[string]$Db,[string]$Table,[string]$Field,[string]$Problem,[string]$Detail,[string]$Suggestion='')
    $Findings.Add([pscustomobject]@{
        Level=$Level; Db=$Db; Table=$Table; Field=$Field; Problem=$Problem; Detail=$Detail; Suggestion=$Suggestion
    }) | Out-Null
}

function SafeName([string]$name) { '[' + $name.Replace(']', ']]') + ']' }

function Count-Rs($db, [string]$sql) {
    try {
        $rs = $db.OpenRecordset($sql)
        $v = $rs.Fields.Item(0).Value
        $rs.Close()
        return $v
    } catch { return $null }
}

function Get-Scalar($db, [string]$sql) {
    try {
        $rs = $db.OpenRecordset($sql)
        if ($rs.EOF) { $rs.Close(); return $null }
        $v = $rs.Fields.Item(0).Value
        $rs.Close()
        return $v
    } catch { return $null }
}

function Is-SystemTable($td) {
    try {
        if ($td.Name -like 'MSys*') { return $true }
        if (($td.Attributes -band -2147483646) -ne 0) { return $true }
    } catch {}
    return $false
}

function Type-Name($t) {
    switch ($t) {
        1 {'Boolean'} 2 {'Byte'} 3 {'Integer16'} 4 {'Long32'} 5 {'Currency'} 6 {'Single'} 7 {'Double'} 8 {'Date'} 10 {'Text'} 11 {'OLE'} 12 {'Memo'} 15 {'GUID'} 20 {'Decimal'} default {"Type_$t"}
    }
}

function Looks-NumericField([string]$name) {
    return ($name -match '(?i)(laudo|sueldo|valor|monto|importe|cantidad|jornal|hora|horas|porc|porcentaje|salario|nominal|precio|tasa|codigo|cod)')
}

function Analyze-Database([string]$label, [string]$path) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Finding 'FAIL' $label '' '' 'Base no encontrada' $path 'Restaurar base desde respaldo.'
        return
    }
    try {
        $dao = New-Object -ComObject DAO.DBEngine.120
        $db = $dao.OpenDatabase($path)
        Add-Finding 'OK' $label '' '' 'Base abre correctamente' $path ''
    } catch {
        Add-Finding 'FAIL' $label '' '' 'No abre la base con DAO' $_.Exception.Message 'Revisar DAO/Access o corrupcion de base.'
        return
    }

    foreach ($td in $db.TableDefs) {
        if (Is-SystemTable $td) { continue }
        $table = $td.Name
        $qTable = SafeName $table
        $rowCount = Count-Rs $db "SELECT COUNT(*) FROM $qTable"
        Add-Finding 'INFO' $label $table '' 'Tabla detectada' "$rowCount registros" ''

        foreach ($f in $td.Fields) {
            $field = $f.Name
            $qField = SafeName $field
            $type = [int]$f.Type
            $typeName = Type-Name $type
            $size = $null
            try { $size = $f.Size } catch {}
            Add-Finding 'INFO' $label $table $field 'Campo detectado' "$typeName Size=$size Required=$($f.Required)" ''

            # Nulls in required fields
            try {
                if ($f.Required -eq $true) {
                    $cNull = Count-Rs $db "SELECT COUNT(*) FROM $qTable WHERE $qField IS NULL"
                    if ($cNull -gt 0) { Add-Finding 'WARN' $label $table $field 'Campo requerido con NULL' "$cNull registros" 'Corregir valores nulos.' }
                }
            } catch {}

            # Numeric overflow risk in 16-bit Integer fields
            if ($type -eq 3) {
                $min = Get-Scalar $db "SELECT MIN($qField) FROM $qTable WHERE $qField IS NOT NULL"
                $max = Get-Scalar $db "SELECT MAX($qField) FROM $qTable WHERE $qField IS NOT NULL"
                if ($null -ne $min -or $null -ne $max) {
                    if (($null -ne $min -and [double]$min -lt -32768) -or ($null -ne $max -and [double]$max -gt 32767)) {
                        Add-Finding 'FAIL' $label $table $field 'Riesgo Error 6 Overflow Integer16' "MIN=$min MAX=$max" 'Campo Integer16 con valor fuera de rango. Revisar datos o tipo de campo.'
                    } else {
                        Add-Finding 'OK' $label $table $field 'Rango Integer16 OK' "MIN=$min MAX=$max" ''
                    }
                }
            }

            # Date ranges
            if ($type -eq 8) {
                $minD = Get-Scalar $db "SELECT MIN($qField) FROM $qTable WHERE $qField IS NOT NULL"
                $maxD = Get-Scalar $db "SELECT MAX($qField) FROM $qTable WHERE $qField IS NOT NULL"
                if ($null -ne $minD -or $null -ne $maxD) {
                    $bad = $false
                    try { if ($minD -and ([datetime]$minD).Year -lt 1990) { $bad = $true } } catch {}
                    try { if ($maxD -and ([datetime]$maxD).Year -gt 2100) { $bad = $true } } catch {}
                    if ($bad) { Add-Finding 'WARN' $label $table $field 'Fecha fuera de rango esperado' "MIN=$minD MAX=$maxD" 'Revisar fechas viejas/futuras.' }
                    else { Add-Finding 'OK' $label $table $field 'Rango fecha OK' "MIN=$minD MAX=$maxD" '' }
                }
            }

            # Text fields that look numeric: detect dots, empty spaces, non-numeric values
            if ($type -eq 10 -and (Looks-NumericField $field)) {
                try {
                    $rs = $db.OpenRecordset("SELECT $qField FROM $qTable WHERE $qField IS NOT NULL")
                    $badCount = 0
                    $examples = New-Object System.Collections.Generic.List[string]
                    while (!$rs.EOF) {
                        $raw = [string]$rs.Fields.Item(0).Value
                        $s = $raw.Trim()
                        if ($s -ne '') {
                            $norm = $s.Replace('.', ',')
                            $num = 0.0
                            $ok = [double]::TryParse($norm, [System.Globalization.NumberStyles]::Any, [System.Globalization.CultureInfo]::GetCultureInfo('es-UY'), [ref]$num)
                            if (!$ok -or $s -eq '.' -or $s -eq ',' -or $s -match '^[^0-9\-\,\.]+$') {
                                $badCount++
                                if ($examples.Count -lt 8) { $examples.Add($raw) | Out-Null }
                            }
                        }
                        $rs.MoveNext()
                    }
                    $rs.Close()
                    if ($badCount -gt 0) { Add-Finding 'WARN' $label $table $field 'Campo textual con pinta numerica contiene valores no numericos' "$badCount registros. Ejemplos: $($examples -join ' | ')" 'Revisar valores como punto solo, guiones o texto donde el sistema espera numero.' }
                } catch {}
            }
        }
    }

    # Targeted diagnostics for Cargos screen
    foreach ($cargoTable in @('Cargos','Cargo','Cargos_Empleados')) {
        try {
            $exists = $false
            foreach ($td in $db.TableDefs) { if ($td.Name -eq $cargoTable) { $exists = $true } }
            if (!$exists) { continue }
            $rs = $db.OpenRecordset("SELECT * FROM " + (SafeName $cargoTable))
            $n = 0
            while (!$rs.EOF -and $n -lt 50) {
                $parts = @()
                for ($i=0; $i -lt $rs.Fields.Count; $i++) {
                    $fn = $rs.Fields.Item($i).Name
                    $fv = $rs.Fields.Item($i).Value
                    $parts += ("$fn=$fv")
                }
                Add-Finding 'INFO' $label $cargoTable '' 'Registro de cargo' ($parts -join ' ; ') ''
                $n++
                $rs.MoveNext()
            }
            $rs.Close()
        } catch {}
    }

    # Targeted relationships by common names
    try {
        $tables = @{}
        foreach ($td in $db.TableDefs) { if (!(Is-SystemTable $td)) { $tables[$td.Name] = $td } }
        if ($tables.ContainsKey('Contrato') -and $tables.ContainsKey('Cargos')) {
            $contr = $tables['Contrato']
            $cargo = $tables['Cargos']
            $contrCargoField = $null
            $cargoIdField = $null
            foreach ($f in $contr.Fields) { if ($f.Name -match '(?i)cargo') { $contrCargoField = $f.Name; break } }
            foreach ($f in $cargo.Fields) { if ($f.Name -match '(?i)id.*cargo|cargo.*id|codigo|cod') { $cargoIdField = $f.Name; break } }
            if ($contrCargoField -and $cargoIdField) {
                $sql = "SELECT COUNT(*) FROM [Contrato] AS c LEFT JOIN [Cargos] AS g ON c." + (SafeName $contrCargoField) + " = g." + (SafeName $cargoIdField) + " WHERE c." + (SafeName $contrCargoField) + " IS NOT NULL AND g." + (SafeName $cargoIdField) + " IS NULL"
                $orph = Count-Rs $db $sql
                if ($orph -gt 0) { Add-Finding 'WARN' $label 'Contrato/Cargos' "$contrCargoField->$cargoIdField" 'Contratos con cargo no encontrado' "$orph registros" 'Revisar cargos vinculados a contratos.' }
                else { Add-Finding 'OK' $label 'Contrato/Cargos' "$contrCargoField->$cargoIdField" 'Vinculo contrato-cargo OK' '0 huerfanos' '' }
            }
        }
    } catch {}

    try { $db.Close() } catch {}
}

Analyze-Database 'Usuarios.mdb' $DbUsuarios
Analyze-Database 'Personal.mdb' $DbEmpresa

# Process / locks
foreach ($lock in @((Join-Path $Base 'Usuarios.ldb'),(Join-Path $Emp 'Personal.ldb'))) {
    if (Test-Path -LiteralPath $lock -PathType Leaf) { Add-Finding 'WARN' 'Sistema' '' '' 'Lock MDB activo' $lock 'Cerrar sistema antes de copiar, compactar o respaldar.' }
    else { Add-Finding 'OK' 'Sistema' '' '' 'Sin lock MDB' $lock '' }
}

# Export
$Findings | Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8

$fail = ($Findings | Where-Object {$_.Level -eq 'FAIL'}).Count
$warn = ($Findings | Where-Object {$_.Level -eq 'WARN'}).Count
$ok = ($Findings | Where-Object {$_.Level -eq 'OK'}).Count
$info = ($Findings | Where-Object {$_.Level -eq 'INFO'}).Count

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('DIAGNOSTICO QUIRURGICO DATOS / OVERFLOW VB6')
$lines.Add('Fecha: ' + (Get-Date))
$lines.Add('Base: ' + $Base)
$lines.Add(('Resumen: OK={0} WARN={1} FAIL={2} INFO={3}' -f $ok,$warn,$fail,$info))
$lines.Add((''.PadLeft(120,'-')))
$lines.Add('PRIORIDAD: revisar primero FAIL, despues WARN. INFO es inventario para diagnostico.')
$lines.Add((''.PadLeft(120,'-')))
foreach ($r in ($Findings | Sort-Object @{Expression={$_.Level};Descending=$false}, Db, Table, Field)) {
    $lines.Add(('[{0}] DB={1} TABLA={2} CAMPO={3} | {4} | {5} | {6}' -f $r.Level,$r.Db,$r.Table,$r.Field,$r.Problem,$r.Detail,$r.Suggestion))
}
$lines.Add((''.PadLeft(120,'-')))
$lines.Add('FIN')
$lines | Set-Content -LiteralPath $Out -Encoding UTF8

Write-Host 'Diagnostico quirurgico generado:'
Write-Host $Out
Write-Host $Csv
Write-Host ('Resumen: OK={0} WARN={1} FAIL={2} INFO={3}' -f $ok,$warn,$fail,$info)
