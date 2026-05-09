# Instrucciones para Codex / agente de desarrollo

## Contexto

Este repositorio corresponde al proyecto de recuperacion y reconstruccion del sistema local de gestion de personal de Valor Humano.

El sistema viejo se llama operativamente GNS Personal PRO / GmsPersonal y parece estar desarrollado en Visual Basic 5/6 con bases Microsoft Access.

El objetivo final no es depender permanentemente del ejecutable viejo, sino construir un sistema propio, local, funcional y mantenible para tercerizacion y gestion de personal.

## Reglas importantes

1. No subir datos reales de empleados, clientes, sueldos, cedulas ni contrasenas.
2. No subir bases `.mdb`, `.accdb`, locks `.ldb`, ejecutables, OCX, DLL ni ZIP completos del sistema viejo.
3. Usar la informacion del sistema viejo solo como referencia funcional y tecnica.
4. Priorizar reconstruccion limpia, documentada y testeable.
5. Mantener compatibilidad conceptual con los modulos detectados: empresas, empleados, contratos, liquidaciones, documentos, legajos, bajas, BSE, MTSS, licencias, costos e informes.

## Carpeta local esperada en la PC del usuario

```txt
C:\GNS Software\GNS Personal PRO\
```

Empresa local objetivo:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\
```

Base de empresa local:

```txt
C:\GNS Software\GNS Personal PRO\Valor Humano\Personal.mdb
```

Base general local:

```txt
C:\GNS Software\GNS Personal PRO\Usuarios.mdb
```

## Prioridades de desarrollo

### Fase 1 - Recuperacion local

- Diagnosticar por que el sistema viejo abre pero no deja empresa activa.
- Revisar configuracion local, rutas antiguas y registro de Windows.
- Confirmar que `Usuarios.mdb` y `Valor Humano\Personal.mdb` existan.
- Confirmar que el listado de empresas apunte a Valor Humano.

### Fase 2 - Documentacion funcional

- Mapear formularios VB6 recuperados.
- Mapear tablas de Access.
- Mapear modulos funcionales.
- Definir modelo de datos limpio.

### Fase 3 - Nuevo sistema

- Crear una app local moderna.
- Mantener datos localmente.
- Implementar login, empresas, empleados, contratos, documentos, novedades, licencias, costos, liquidaciones e informes.
