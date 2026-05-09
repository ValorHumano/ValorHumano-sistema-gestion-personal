# Plan de limpieza de base Valor Humano

## Estado confirmado

La empresa `Valor Humano` ya abre como empresa activa en GNS Personal PRO.

La base analizada es:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\Personal.mdb
```

Se genero respaldo previo en:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\Respaldos\Personal_BACKUP_ANTES_DE_LIMPIAR_20260509_194558.mdb
```

## Conclusion del analisis

La base ya no es una demo a nivel de ruta/conexion: el sistema trabaja contra la carpeta `Valor Humano`.

Pero la base fue copiada desde `Demo Ind. y Comercio`, por lo que conserva datos operativos de ejemplo:

- Personas: 12 registros.
- Contratos: 11 registros.
- Legajos: 44 registros.
- Encabezados de liquidacion: 1624 registros.
- Datos de liquidacion: 9426 registros.
- Datos de aportes: 7538 registros.
- Licencias: 150 registros.
- Planificacion de licencia: 59 registros.
- MTSS y detalle: registros heredados.
- Pagos en sueldo y detalle: registros heredados.

## Criterio de limpieza

No se debe vaciar toda la base. Hay tablas maestras y parametros que mantienen vivo el sistema.

### Conservar

Conservar tablas de configuracion, conceptos, parametros, tipos, valores, localidades y tablas maestras:

```txt
Empresa
Conceptos
Funciones
Valores
TiposLiquidacion
Tipo_*
Tipos_*
TasaIRPF
TasaDedIRPF
Bancos
Dpto
Localidades
Paises
Sexo
EstadosCiviles
Nacionalidad
NaturalezaJuridica
Documentos_Exigidos
Formas_de_Pago
Monedas
CausalesEgr
Categorias
Cargos
Sectores
Sucursales
TRegHorario
r_TAporTContVFunc
rCobraPor_TipoRem
rConcepto_Lic
rAporPat_TipoLiq
```

### Limpiar en fase 1

Limpiar datos operativos heredados de empleados, contratos, liquidaciones, legajos, MTSS, licencias, pagos y relaciones personales:

```txt
ArchVincFunc
AuxContrato
AuxCostoEmp
AuxDatosExcel
AuxDeducciones
AuxDetaIRPF
AuxDetaSV
AuxDetaSVDeta
AuxEncIRPF
AuxFocer
AuxHistLab
AuxHistLabObras
AuxHistLabPrev
AuxHLActu
AuxHLComp
AuxImpPagos
AuxMTSSDeta
AuxMTSSObs
AuxMTSSRem
AuxOtrosRep
AuxTablaParaRepBSE
Avisos
Calendario_Liq
CierraMeses
ContratoAportaX
ContratosEnSeguro
Declaraciones
Datos_deAportes
Datos_Liquidacion
Encabezados
ImagenEmp
Impresion
Legajo
LegajoDatoModif
LegajoEmpresa
Licencias
Lotes
LotesHistorico
LotesRepEsp
Memos
MensajesEnRec
MTSS
MTSSDeta
MTSSObs
MTSSRem
PagosEnSueldo
PagosEnSueldoDeta
PersonasRela
PlanificDeLicencia
rCC_Cont
rContRepEsp
rEmpleado_Documentos
rLic_Enc
rPersonas_Dto_Comunicacion
rPlanillas
SueldosConf
WebContHabil
WebDatosExp
Contrato
Personas
```

## Orden critico

La limpieza debe hacerse de tablas hijas a tablas padre. `Personas` y `Contrato` van al final, no al principio.

## Despues de limpiar

1. Abrir GNS Personal PRO desde `tools/abrir_gns_local.bat`.
2. Confirmar que `Empresa Actual: Valor Humano` sigue apareciendo.
3. Confirmar que Fichas Personales no muestre empleados demo.
4. Completar datos reales en `Datos de la Empresa`.
5. Crear el primer empleado real de prueba.
6. Crear contrato de prueba.
7. Probar legajo, licencia, liquidacion y recibo.

## Fase posterior

Despues de validar estabilidad, limpiar o adaptar datos maestros como cargos, sectores, sucursales, categorias y conceptos segun uso real de Valor Humano.
