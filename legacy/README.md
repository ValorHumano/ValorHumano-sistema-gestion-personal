# Legacy GNS Personal PRO

Esta carpeta documenta el material legado recuperado, pero no contiene binarios ni datos sensibles.

## Material disponible fuera del repo

El usuario tiene localmente:

```txt
GNS Personal PRO.zip
GmsPersonal_Exportado.zip
Personal.mdb
Personal(1).mdb
Carpeta local: C:\GNS Software\GNS Personal PRO
```

## Motivo para no subirlo directamente

No se deben subir al repo:

```txt
*.mdb
*.ldb
*.exe
*.dll
*.ocx
*.oca
*.lib
*.exp
*.zip
```

porque pueden contener datos personales, configuracion interna, licencias, componentes propietarios o dependencias antiguas.

## Uso correcto

El material legado se usa para:

- Inventariar formularios.
- Entender modulos del sistema.
- Mapear tablas Access.
- Reconstruir flujos funcionales.
- Crear un sistema nuevo propio y mantenible.

## Exportacion decompilada

La exportacion con Semi VB Decompiler genero:

```txt
95 formularios .frm
12 modulos .bas
33 clases .cls
19 user controls .ctl
12 recursos .frx
ProSueldos.vbp
```

La logica interna de procedimientos aparece mayormente vacia, por lo cual no se puede recompilar el sistema completo solo con la exportacion.
