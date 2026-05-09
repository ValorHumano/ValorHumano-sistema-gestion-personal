# Rebranding basico sin romper

## Objetivo

Que el sistema parezca otra aplicacion, usando el nombre:

```txt
Sistema de Gestion
```

sin romper la instalacion vieja que ya funciona.

## Regla de seguridad

No modificar directamente:

```txt
C:\GNS Software\GNS Personal PRO\GnsPersonal.exe
```

Trabajar siempre sobre una copia:

```txt
C:\GNS Software\GNS Personal PRO\SistemaGestion.exe
```

## Que se puede cambiar con bajo riesgo

- Nombre del acceso directo.
- Icono del acceso directo.
- Nombre de la copia del ejecutable.
- Textos de informacion de version si se editan sobre copia.
- Imagenes externas, si existen.

## Que no conviene cambiar directo sin copia

- Ejecutable original.
- DLL.
- OCX.
- Bases MDB.
- Controles VB6.

## Cambios visibles esperados

### Entrada al sistema

Usar acceso directo:

```txt
Sistema de Gestion
```

apuntando a:

```txt
C:\GNS Software\GNS Personal PRO\SistemaGestion.exe
```

### Textos internos

Intentar cambiar sobre la copia:

```txt
GNS Personal -> Sistema de Gestion
GNS Personal PRO -> Sistema de Gestion
Version Evaluacion -> Sistema Local
Zinco Software -> Sistema Local
```

## Procedimiento manual recomendado

1. Cerrar el sistema.
2. Copiar `GnsPersonal.exe`.
3. Pegar copia en la misma carpeta.
4. Renombrar la copia como `SistemaGestion.exe`.
5. Crear acceso directo al escritorio llamado `Sistema de Gestion`.
6. Probar que abre.
7. Si abre, usar esa copia para pruebas visuales.
8. Si no abre, borrar la copia y volver al original.

## Sobre el splash/logo GNS

La pantalla inicial con logo probablemente esta embebida dentro del ejecutable o en recursos VB6. Para cambiarla sin riesgo hay que trabajar sobre `SistemaGestion.exe`, nunca sobre `GnsPersonal.exe`.

Si Semi VB Decompiler permite editar `File Version Information` o recursos visuales, hacer cambios solo en la copia y probar.

## Estado final aceptable para etapa basica

- El usuario abre desde `Sistema de Gestion`.
- No se usan accesos viejos con GNS.
- El original queda intacto.
- Si algo falla, se vuelve a abrir desde `GnsPersonal.exe`.
