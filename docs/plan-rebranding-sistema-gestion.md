# Plan de rebranding seguro - Sistema de Gestion

## Objetivo

Quitar o reducir referencias visibles a `GNS`, `GNS Personal PRO`, `Zinco` y marcas antiguas, reemplazandolas por una identidad neutra:

```txt
Sistema de Gestion
```

## Regla principal

No romper el sistema viejo funcionando. Toda modificacion debe ser reversible y con respaldo previo.

## Niveles de rebranding

### Nivel 1 - Seguro

Cambios externos y reversibles:

- Renombrar accesos directos.
- Crear lanzador con nombre `Sistema de Gestion`.
- Reemplazar imagenes/logo externos si el sistema los carga desde carpetas.
- Ajustar archivos `.ini`, `.txt`, `.url` si contienen texto visible.
- Crear respaldo de todo lo reemplazado.

### Nivel 2 - Medio

Cambios en bases/configuracion:

- Revisar `Usuarios.mdb`, `Personal.mdb` y campos de empresa.
- Cambiar nombre visible de empresa a `Valor Humano`.
- Cambiar razon social, RUT, correo, telefono y datos institucionales.
- Cambiar textos de pie de impresion o reportes cuando esten en base/configuracion.

### Nivel 3 - Riesgoso

Cambios dentro del ejecutable viejo:

- Titulo de ventana `GNS Personal`.
- Texto `Version Evaluacion`.
- Icono embebido del programa.
- Recursos compilados VB6.

Estos cambios pueden requerir Resource Hacker, recompilacion VB6 o parche binario. No deben hacerse hasta tener una copia ejecutable de prueba.

## Estrategia recomendada

1. Primero hacer inventario de marca en archivos externos.
2. Reemplazar solo archivos externos y textos configurables.
3. Probar apertura de empresa `Valor Humano`.
4. Luego evaluar si conviene parchear el EXE o dejar ese cambio para la reconstruccion nueva.

## Nombre objetivo

```txt
Sistema de Gestion
```

Variante para titulos largos:

```txt
Sistema de Gestion - Valor Humano
```

## Colores recomendados

Para mantener sobriedad y evitar romper controles VB6:

- Fondo principal: grafito / gris oscuro ya existente.
- Acento: naranja actual o reemplazo por gris plata/champagne suave si el sistema permite assets externos.
- Evitar cambios globales de color en el EXE viejo sin recompilar.

## Archivos que se pueden tocar con menos riesgo

```txt
*.ini
*.txt
*.url
Imagenes\*
Logo externo si existe
Accesos directos
Iconos externos
```

## Archivos que NO se deben modificar directamente sin respaldo

```txt
GnsPersonal.exe
*.dll
*.ocx
Usuarios.mdb
Personal.mdb
```

Las bases se pueden modificar solo con scripts controlados y respaldo automatico.
