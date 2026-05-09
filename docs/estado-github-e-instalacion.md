# Estado del repositorio y plan de instalacion en otra PC

## Diagnostico honesto

El repositorio GitHub actualmente NO contiene el programa completo instalable.

Contiene principalmente:

- Documentacion tecnica.
- Diagnosticos.
- Scripts de reparacion.
- Scripts de limpieza.
- Scripts de rebranding.
- Instrucciones para reconstruccion.

No contiene los binarios reales necesarios para instalar el sistema completo en otra PC.

## Por que no esta completo en GitHub

Se evito subir al repositorio publico archivos sensibles o binarios pesados:

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

Estos archivos son necesarios para instalar el sistema viejo en otra PC, pero no conviene subirlos a un repositorio publico porque pueden contener:

- Datos internos.
- Bases Access.
- Componentes propietarios.
- Configuracion local.
- Dependencias antiguas.

## Archivos locales necesarios para instalar en otra PC

La instalacion funcional actual esta en:

```txt
C:\GNS Software\GNS Personal PRO\
```

Para instalar en otra PC se necesita llevar un paquete con:

```txt
SistemaGestion.exe
GnsPersonal.exe
Usuarios.mdb
Configura.ini
ConfiguraSis.ini
ListEmpresas.ini
ListEmpresas
Update.ini
ValoresComunes.ini
Reportes\
Utiles\
Imagenes\
Manual de Usuario\
Valor Humano\Personal.mdb
Valor Humano\HistorialLaboral\
Valor Humano\imgEmpleados\
Valor Humano\MTSS\
Valor Humano\Reportes\
Valor Humano\Respaldos\  (opcional, normalmente excluir)
*.ocx
*.dll
*.oca
*.lib
*.exp
```

## Recomendacion

No subir el paquete completo al repositorio publico.

Opciones seguras:

### Opcion A - Mantener GitHub solo para scripts/documentacion

Crear el paquete instalable localmente en la PC actual y guardarlo en pendrive, Google Drive privado o disco externo.

### Opcion B - Convertir repositorio a privado

Si se quiere subir el paquete completo a GitHub, primero convertir el repo a privado.

Aun asi, conviene subir el paquete como Release o archivo ZIP, no mezclado con el codigo.

### Opcion C - Crear instalador local

Usar los scripts del repo:

```txt
tools\preparar_paquete_instalacion_local.bat
tools\instalar_sistema_gestion_nueva_pc.bat
```

El primero crea un ZIP desde la PC donde ya funciona.
El segundo se ejecuta en la PC nueva para copiar archivos, configurar registro, registrar OCX/DLL y crear acceso directo.

## Flujo recomendado

En la PC actual:

1. Verificar que `SistemaGestion.exe` abra correctamente.
2. Verificar que la empresa limpia abra correctamente.
3. Ejecutar `preparar_paquete_instalacion_local.bat`.
4. Copiar el ZIP generado a la PC nueva.

En la PC nueva:

1. Extraer el ZIP en una carpeta temporal.
2. Ejecutar `instalar_sistema_gestion_nueva_pc.bat` como administrador.
3. Abrir desde el acceso directo `Sistema de Gestion`.
4. Probar login, empresa, empleados, liquidaciones e informes.

## Estado actual del proyecto

- Programa viejo funcionando en la PC actual: si.
- Empresa Valor Humano creada/limpia: si, segun logs de limpieza.
- Rebranding basico sobre copia `SistemaGestion.exe`: hecho localmente.
- GitHub listo para documentar y generar scripts: si.
- GitHub contiene instalador completo con binarios: no.

## Proximo paso

Crear el ZIP instalable local desde la PC actual usando `preparar_paquete_instalacion_local.bat`.
