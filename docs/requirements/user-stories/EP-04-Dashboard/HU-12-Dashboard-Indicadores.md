# HU-12: Visualizar dashboard de indicadores

## 1. Información general

- **ID:** HU-12
- **Épica:** EP-04 — Dashboard e indicadores de atención
- **Prioridad:** Alta
- **Actor:** supervisor o administrador
- **Alcance de la historia (según RF):** AL-05
- **Alcance de la épica:** AL-05
- **Requisitos funcionales asociados:** RF-16
- **Pantalla vinculada (Fase I):** — (Fase II)

## 2. Historia de usuario

Como supervisor o administrador, quiero visualizar un dashboard con los 9 indicadores clave de atención (registradas, pendientes, atendidas, por categoría, por prioridad, por responsable, tiempo promedio, porcentaje de resueltas y vencidas), para evaluar el desempeño del servicio y tomar decisiones.

## 3. Criterios de aceptación

- **CA-01:** El dashboard es accesible únicamente para los roles Supervisor y Administrador.
- **CA-02:** Muestra los 9 indicadores acordados: solicitudes registradas, pendientes, atendidas, por categoría, por prioridad, por responsable, tiempo promedio de atención, porcentaje de solicitudes resueltas y solicitudes vencidas (mostrando este último como «No disponible» hasta implementar el módulo de SLA en RF-21).

## 4. Escenarios BDD

### Escenario 12.1 – Consulta del dashboard de indicadores (Flujo correcto)

**Dado** que un supervisor o administrador ha iniciado sesión en el sistema  
**Cuando** accede a la sección «Dashboard»  
**Entonces** el sistema calcula y muestra los indicadores de solicitudes registradas, pendientes, atendidas, porcentaje de resueltas, tiempo promedio y sus distribuciones por categoría, prioridad y responsable.  

---

**Fuente:** Informe de Gestal, sección 9.2 (historia de usuario) y sección 11 (criterios de aceptación y escenarios BDD, cuando están documentados).
