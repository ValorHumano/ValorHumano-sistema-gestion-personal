# Plan de recuperacion local

## Objetivo inmediato

Dejar funcionando el sistema viejo en la PC local con la empresa `Valor Humano` como empresa activa.

## Problema actual

El programa abre la interfaz, pero no logra abrir ninguna empresa. Mientras no haya empresa abierta, las herramientas, menu, agregar, quitar, guardar, empleados, liquidaciones e informes no van a funcionar.

## Causa probable

El sistema conserva rutas antiguas de instalacion. El mensaje de arranque indica que primero intenta conectar con una base general ubicada en una ruta vieja de `Downloads` y luego intenta usar la carpeta local.

La base general esperada es:

```txt
C:\GNS Software\GNS Personal PRO\Usuarios.mdb
```

La base de empresa esperada es:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\Personal.mdb
```

## Checklist de verificacion local

Verificar que existan estos archivos y carpetas:

```txt
C:\GNS Software\GNS Personal PRO\GnsPersonal.exe
C:\GNS Software\GNS Personal PRO\Usuarios.mdb
C:\GNS Software\GNS Personal PRO\Configura.ini
C:\GNS Software\GNS Personal PRO\ConfiguraSis.ini
C:\GNS Software\GNS Personal PRO\ListEmpresas.ini
C:\GNS Software\GNS Personal PRO\Valor Humano\Personal.mdb
C:\GNS Software\GNS Personal PRO\Valor Humano\HistorialLaboral
C:\GNS Software\GNS Personal PRO\Valor Humano\imgEmpleados
C:\GNS Software\GNS Personal PRO\Valor Humano\MTSS
C:\GNS Software\GNS Personal PRO\Valor Humano\Reportes
C:\GNS Software\GNS Personal PRO\Valor Humano\Respaldos
```

## Contenido esperado de ListEmpresas.ini

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano <-> Valor Humano
```

## Secuencia de trabajo

1. Confirmar si el archivo real se llama `ListEmpresas` o `ListEmpresas.ini` en Windows.
2. Verificar que la linea de Valor Humano este en el archivo real de la raiz, no dentro de la carpeta de empresa.
3. Revisar valores guardados en la configuracion global del sistema.
4. Corregir las rutas antiguas que apuntan a Downloads.
5. Abrir el sistema.
6. Seleccionar Valor Humano.
7. Confirmar que abajo ya no diga `No hay ninguna empresa abierta`.
8. Recién ahi probar menu, empleados, agregar, quitar, guardar e informes.

## Pendiente tecnico

Crear una herramienta local de diagnostico que lea:

- Rutas principales.
- Archivo de lista de empresas.
- Configura.ini.
- ConfiguraSis.ini.
- Valores de configuracion de Windows usados por el sistema.
- Existencia de dependencias OCX/DLL.

Esa herramienta debe generar un reporte de texto para pegar en ChatGPT.
