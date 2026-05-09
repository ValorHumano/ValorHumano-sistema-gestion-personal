# Valor Humano - Sistema de gestion de personal local

Repositorio de recuperacion, diagnostico y reconstruccion del sistema local de gestion de personal para Valor Humano.

## Objetivo

Construir un sistema 100% funcional para uso local en PC, orientado a tercerizacion y gestion de personal, usando como referencia tecnica y funcional el sistema viejo GNS Personal PRO / GmsPersonal.

## Estado actual

Se esta trabajando en dos frentes:

1. Recuperar el funcionamiento local del sistema viejo.
2. Documentar y reconstruir un sistema propio, limpio y mantenible.

El sistema viejo abre la interfaz, pero no queda funcional porque no logra abrir correctamente una empresa/base activa. La evidencia indica que conserva rutas viejas en el registro de Windows y depende de una base general `Usuarios.mdb`, una base por empresa `Personal.mdb`, archivos `.ini` y componentes VB6/OCX.

## Estructura del repo

```txt
docs/
  diagnostico-sistema-viejo.md
  inventario-tecnico.md
  plan-recuperacion-local.md
  plan-reconstruccion.md
legacy/
  README.md
tools/
  diagnostico_local_gns.ps1
  reparar_rutas_gns.ps1
  verificar_estructura_empresa.ps1
```

## Importante sobre archivos sensibles

Este repositorio no debe contener bases reales, ejecutables viejos ni componentes propietarios.

No subir:

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
Datos reales de empleados/clientes
Contraseñas
Backups completos del sistema viejo
```

Los archivos binarios y bases deben quedar solo en la PC local.

## Carpeta local esperada

```txt
C:\GNS Software\GNS Personal PRO\
```

Empresa local esperada:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\
```

Con base de empresa:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\Personal.mdb
```

## Proximo paso operativo

Ejecutar en Windows PowerShell el diagnostico:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\tools\diagnostico_local_gns.ps1
```

Luego pegar en ChatGPT el contenido del archivo generado en:

```txt
C:\GNS Software\GNS Personal PRO\diagnostico_gns_local.txt
```
