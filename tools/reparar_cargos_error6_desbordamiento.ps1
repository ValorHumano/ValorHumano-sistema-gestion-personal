$ErrorActionPreference = 'Stop'

# REPARAR ERROR 6 DESBORDAMIENTO EN CARGOS
# Hace backup de Personal.mdb antes de modificar.
# Corrige valores nulos en Cargos.Laudo y Cargos.id_CobraPor que pueden verse como '.' en la pantalla.

$Base = 'C:\GNS Software\GNS Personal PRO'
$Emp = Join-Path $Base 'Valor Humano'
$DbPath = Join-Path $Emp 'Personal.mdb'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$BackupDir = Join-Path $Base '_Backups_Reparaciones'
$BackupPath = Join-Path $BackupDir "Personal_antes_reparar_cargos_error6_$Stamp.mdb"
$Log = Join-Path $Base "reparar_cargos_error6_desbordamiento_$Stamp.txt"

function LogLine([string]$s) {
    $s | Tee-Object -FilePath $Log -Append
}

if (!(Test-Path -LiteralPath $DbPath -PathType Leaf)) {
    throw "No existe base de empresa: $DbPath"
}

if (!(Test-Path -LiteralPath $BackupDir -PathType Container)) {
    New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
}

Copy-Item -LiteralPath $DbPath -Destination $BackupPath -Force

LogLine 'REPARAR CARGOS - ERROR 6 DESBORDAMIENTO'
LogLine ('Fecha: ' + (Get-Date))
LogLine ('Base: ' + $DbPath)
LogLine ('Backup: ' + $BackupPath)
LogLine ''.PadLeft(90,'-')

$dao = New-Object -ComObject DAO.DBEngine.120
$db = $dao.OpenDatabase($DbPath)

try {
    LogLine '1) Tipos_CobraPor disponibles:'
    $rs = $db.OpenRecordset('SELECT id_CobraPor, Codigo, Descripcion FROM Tipos_CobraPor ORDER BY id_CobraPor')
    while (!$rs.EOF) {
        LogLine ('  id={0} Codigo={1} Descripcion={2}' -f $rs.Fields.Item('id_CobraPor').Value, $rs.Fields.Item('Codigo').Value, $rs.Fields.Item('Descripcion').Value)
        $rs.MoveNext()
    }
    $rs.Close()

    $idHora = $null
    $rs = $db.OpenRecordset("SELECT TOP 1 id_CobraPor FROM Tipos_CobraPor WHERE Codigo='H' OR Descripcion LIKE '*Hora*' ORDER BY id_CobraPor")
    if (!$rs.EOF) { $idHora = [int]$rs.Fields.Item('id_CobraPor').Value }
    $rs.Close()

    if ($null -eq $idHora) {
        throw "No pude detectar id_CobraPor para Hora. No modifico nada mas. Revise Tipos_CobraPor."
    }

    LogLine ('2) id_CobraPor detectado para Hora: ' + $idHora)
    LogLine '3) Cargos antes de corregir:'
    $rs = $db.OpenRecordset('SELECT idEmpresa, ID_Cargo, CARGO, Laudo, id_CobraPor, Id_Cat FROM Cargos ORDER BY ID_Cargo')
    while (!$rs.EOF) {
        LogLine ('  idEmpresa={0} ID_Cargo={1} CARGO={2} Laudo={3} id_CobraPor={4} Id_Cat={5}' -f $rs.Fields.Item('idEmpresa').Value, $rs.Fields.Item('ID_Cargo').Value, $rs.Fields.Item('CARGO').Value, $rs.Fields.Item('Laudo').Value, $rs.Fields.Item('id_CobraPor').Value, $rs.Fields.Item('Id_Cat').Value)
        $rs.MoveNext()
    }
    $rs.Close()

    LogLine '4) Aplicando correcciones seguras en Cargos...'
    $db.Execute('UPDATE Cargos SET Laudo=0 WHERE Laudo IS NULL')
    LogLine ('  Laudo NULL -> 0 | registros afectados=' + $db.RecordsAffected)

    $db.Execute('UPDATE Cargos SET id_CobraPor=' + $idHora + ' WHERE id_CobraPor IS NULL')
    LogLine ('  id_CobraPor NULL -> Hora | registros afectados=' + $db.RecordsAffected)

    LogLine '5) Cargos despues de corregir:'
    $rs = $db.OpenRecordset('SELECT idEmpresa, ID_Cargo, CARGO, Laudo, id_CobraPor, Id_Cat FROM Cargos ORDER BY ID_Cargo')
    while (!$rs.EOF) {
        LogLine ('  idEmpresa={0} ID_Cargo={1} CARGO={2} Laudo={3} id_CobraPor={4} Id_Cat={5}' -f $rs.Fields.Item('idEmpresa').Value, $rs.Fields.Item('ID_Cargo').Value, $rs.Fields.Item('CARGO').Value, $rs.Fields.Item('Laudo').Value, $rs.Fields.Item('id_CobraPor').Value, $rs.Fields.Item('Id_Cat').Value)
        $rs.MoveNext()
    }
    $rs.Close()

    LogLine '6) Contratos con cargo inexistente:'
    $sql = 'SELECT c.Id_Contrato, c.Id_Persona, c.id_Cargo, c.FECHA_INICIO, c.vigente FROM Contrato AS c LEFT JOIN Cargos AS g ON c.id_Cargo = g.ID_Cargo WHERE c.id_Cargo IS NOT NULL AND g.ID_Cargo IS NULL'
    $rs = $db.OpenRecordset($sql)
    $orph = 0
    while (!$rs.EOF) {
        $orph++
        LogLine ('  ORFANO Id_Contrato={0} Id_Persona={1} id_Cargo={2} FechaInicio={3} vigente={4}' -f $rs.Fields.Item('Id_Contrato').Value, $rs.Fields.Item('Id_Persona').Value, $rs.Fields.Item('id_Cargo').Value, $rs.Fields.Item('FECHA_INICIO').Value, $rs.Fields.Item('vigente').Value)
        $rs.MoveNext()
    }
    $rs.Close()
    if ($orph -eq 0) { LogLine '  OK: no hay contratos huerfanos.' }
    else { LogLine '  AVISO: hay contratos huerfanos. No los modifique automaticamente para no cambiar datos laborales.' }

    LogLine ''.PadLeft(90,'-')
    LogLine 'FIN OK. Abra el sistema y pruebe Datos Basicos > Cargos nuevamente.'
}
finally {
    try { $db.Close() } catch {}
}
