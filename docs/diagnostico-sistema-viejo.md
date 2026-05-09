# Diagnostico del sistema viejo GNS Personal PRO / GmsPersonal

## Objetivo del diagnostico

Recuperar y dejar funcionando localmente una version vieja propia del sistema GNS Personal PRO / GmsPersonal, para luego usar su estructura funcional como base de reconstruccion de un sistema propio para Valor Humano.

## Hallazgos principales

### Tecnologia aparente

- Visual Basic 5/6.
- Base de datos Microsoft Access.
- Proyecto recuperado con Semi VB Decompiler 0.09.
- Ejecutable identificado como `GnsPersonal.exe` / `GmsPersonal.exe`.
- Producto/titulo interno detectado: `GNS Personal PRO`.
- Proyecto decompilado principal: `ProSueldos.vbp`.

### Exportacion del decompiler

La opcion usada fue:

```txt
File -> Generate VBP
```

Resultado aproximado:

```txt
95 formularios .frm
12 modulos .bas
33 clases .cls
19 user controls .ctl
12 recursos .frx
Proyecto principal: ProSueldos.vbp
```

El decompiler recupero estructura visual, formularios, controles y nombres de procedimientos/eventos, pero los cuerpos de los procedimientos estan mayormente vacios. Por tanto, el exportado sirve como plano visual/funcional, no como codigo ejecutable completo.

## Componentes / dependencias detectadas

Dependencias relevantes identificadas en el proyecto viejo:

```txt
XceedZip.dll
crviewer9.dll
msadodc.ocx
comdlg32.ocx
ssdw3bo.ocx
mscomct2.ocx
tabctl32.ocx
vbalIml6.ocx
vbaListView6.ocx
vbalTreeView6.ocx
CuadradoColores.ocx
AniGIF.ocx
msflxgrd.ocx
PaComunicar.ocx
mswinsck.ocx
ZincoGrid.ocx
BtnDibu4.ocx
ControlParaRep.ocx
OtrosObjZinco.ocx
cPopMenuZinco.ocx
MsComCtl.ocx
```

## Bases y archivos clave

### Base general

Archivo detectado:

```txt
Usuarios.mdb
```

Funcion probable:

- Usuarios.
- Configuracion global.
- Lista de empresas.
- Permisos.
- Rutas generales.

### Base por empresa

Archivo detectado:

```txt
Personal.mdb
```

Ruta esperada para Valor Humano:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\Personal.mdb
```

Tablas/campos visibles por cadenas internas:

```txt
Empresa
Personas
Contrato
Conceptos
Cargos
Sectores
Sucursales
Bancos
Documentos_Exigidos
ContratosEnSeguro
idEmpresa
Id_Persona
id_Contrato
SUELDO
FECHA_INICIO
FECHA_FIN
RUC
RazonSocial
Nombre
Apellido
id_Cargo
id_Sector
id_Sucursal
```

## Archivos INI / configuracion

### Configura.ini

Usa una cadena de conexion a la base general:

```txt
Provider=Microsoft.Jet.OLEDB.4.0;Data Source='[PathGeneral]Usuarios.mdb'
```

Tambien hace referencia al registro de Windows:

```txt
HKLM\SOFTWARE\Grupo Net Software\Gns Personal
BaseGral
PathAplicacion
```

### Update.ini

Tambien contiene referencias a la ruta de instalacion y registro de Windows.

### ConfiguraSis.ini

Contiene configuracion funcional de liquidacion, MTSS, licencias, agrupaciones, utilidades y confirma que la base de empresa se llama `personal.mdb`:

```txt
[RUTAEMPRESA]personal.mdb
```

Ejemplos detectados:

```txt
Conexión con Relojes*"[APP]Utiles\ImportaHoras.exe" [RUTAEMPRESA]personal.mdb
Importador de Datos*"[APP]Utiles\IG\ImportadorGeneral.exe" ([RUTAEMPRESA]personal.mdb**1)
Importar desde Excel*"[APP]Utiles\ImportarDatos.exe" (*)[RUTAEMPRESA][ARCHDEBD](*)[IDUSU](*)[PASS]
```

### ListEmpresas.ini

Formato detectado:

```txt
[RUTA_EMPRESA] <-> [NOMBRE_VISIBLE]
```

Ejemplo original:

```txt
C:\GNS Software\GNS Personal PRO\Demo Ind. y Comercio <-> Demo Industria y Comercio
```

Empresa Valor Humano propuesta:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano <-> Valor Humano
```

## Estructura de empresa

La carpeta de empresa no es solo la base. Debe contener:

```txt
HistorialLaboral
imgEmpleados
MTSS
Reportes
Respaldos
Personal.mdb
```

Se creo una carpeta local:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano
```

copiada desde:

```txt
C:\GNS Software\GNS Personal PRO\Demo Ind. y Comercio
```

## Sintoma actual

El sistema abre, carga la interfaz y llega a la pantalla `Seleccione una Empresa`, pero no logra abrir ninguna empresa. Las herramientas/menu/agregar/quitar no quedan funcionales porque no hay empresa abierta.

Mensaje observado al iniciar:

```txt
No se pudo conectar con la base de datos General, ubicada en una ruta vieja de Downloads...
Se intentara conectar con la base ubicada localmente en C:\GNS Software\GNS Personal PRO\
```

## Hipotesis tecnica actual

El programa sigue leyendo rutas viejas desde el registro de Windows o desde una base general `Usuarios.mdb` que conserva configuracion anterior.

Rutas de registro candidatas:

```txt
HKLM\SOFTWARE\Grupo Net Software\Gns Personal
HKLM\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal
HKCU\SOFTWARE\Grupo Net Software\Gns Personal
HKCU\SOFTWARE\WOW6432Node\Grupo Net Software\Gns Personal
```

Valores clave:

```txt
BaseGral
PathAplicacion
```

## Prioridad inmediata

1. Diagnosticar registro real de Windows.
2. Corregir rutas `BaseGral` y `PathAplicacion`.
3. Verificar existencia de `Usuarios.mdb` y `Valor Humano\Personal.mdb`.
4. Verificar `ListEmpresas.ini` real en la raiz.
5. Abrir sistema y comprobar si la empresa queda activa.
