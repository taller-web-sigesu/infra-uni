# HU-25: Administrar espacios, horarios y política de reservas

## 1. Información general

- **ID:** HU-25
- **Épica:** EP-07 — Reserva de ambientes
- **Prioridad:** Media
- **Actor:** administrador
- **Alcance de la historia (según RF):** AL-08
- **Alcance de la épica:** AL-08
- **Requisitos funcionales asociados:** RF-30
- **Requisitos no funcionales relacionados (sección 11):** RNF-03, RNF-06
- **Pantalla vinculada (Fase I):** 12. Administración de espacios

## 2. Historia de usuario

Como administrador, quiero gestionar los espacios, sus horarios de atención y la política de reservas, para mantener actualizada la oferta de ambientes y las reglas de uso.

## 3. Criterios de aceptación

- **CA-01:** El administrador puede crear, editar y desactivar espacios con código único, nombre, tipo, área responsable, pabellón, piso, capacidad mayor que cero y la marca `requiere_aprobacion`.
- **CA-02:** El administrador puede definir el horario semanal por espacio (día, hora de apertura y cierre) sin solapamientos para el mismo día.
- **CA-03:** El administrador puede configurar la política vigente: duración mínima y máxima, anticipación mínima y máxima, y límite de reservas activas por día.
- **CA-04:** Desactivar un espacio impide nuevas reservas, pero conserva las reservas existentes y su historial.
- **CA-05:** El sistema no elimina físicamente un espacio que tenga reservas; aplica baja lógica.

## 4. Escenarios BDD

### Escenario 25.1 – Creación de un espacio sin capacidad (Validación)

**Dado** que el administrador se encuentra en el formulario de alta de espacios  
**Cuando** completa los datos pero deja la capacidad vacía o en cero y presiona «Guardar»  
**Entonces** el sistema no guarda el espacio  
**Y** muestra un mensaje indicando que la capacidad debe ser mayor que cero.  

### Escenario 25.2 – Desactivación de un espacio con reservas futuras (Flujo correcto)

**Dado** que un espacio tiene reservas futuras confirmadas  
**Cuando** el administrador lo desactiva  
**Entonces** el espacio deja de aparecer para nuevas reservas  
**Y** las reservas existentes se conservan con su historial.  

### Escenario 25.3 – Horario con cierre anterior a la apertura (Validación)

**Dado** que el administrador edita el horario semanal de un espacio  
**Cuando** ingresa hora de apertura 18:00 y hora de cierre 08:00  
**Entonces** el sistema no guarda el horario  
**Y** muestra un mensaje indicando que el cierre debe ser posterior a la apertura.  

---

**Fuente:** Requisito aprobado por el equipo para la extensión EP-07 (RF-30); criterios y escenarios definidos para esta historia.
