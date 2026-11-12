# Requisitos no funcionales — Gestal

| ID | Categoría | Requerimiento | Prioridad |
| :---: | :---: | ----- | :---: |
| RNF-01 | Usabilidad | La interfaz debe ser responsive y usable desde 360 px de ancho (móvil) hasta escritorio. | Alta |
| RNF-02 | Usabilidad | Un solicitante debe poder registrar una solicitud en no más de 3 pasos después de iniciar sesión. | Alta |
| RNF-03 | Usabilidad | Los formularios deben mostrar mensajes de validación junto a cada campo, confirmaciones de las acciones y estados vacíos. | Alta |
| RNF-04 | Usabilidad | La interfaz debe cumplir buenas prácticas básicas de accesibilidad: etiquetas en los campos, contraste suficiente y navegación con teclado. | Media |
| RNF-05 | Seguridad | Las contraseñas deben almacenarse con un algoritmo de hash seguro, nunca en texto plano. | Alta |
| RNF-06 | Seguridad | Toda operación, salvo el inicio de sesión y el auto-registro (HU-27), debe requerir autenticación (JWT o sesión) y respetar la autorización por rol. | Alta |
| RNF-07 | Seguridad | Las entradas deben validarse en el frontend y en el backend para prevenir inyección y XSS, siguiendo los principios OWASP. | Alta |
| RNF-08 | Seguridad | Los secretos (claves, credenciales de base de datos) deben gestionarse con variables de entorno, sin valores fijos en el código. | Alta |
| RNF-09 | Rendimiento | Las operaciones habituales (listar, consultar detalle, registrar) deben responder en menos de 2 segundos con la carga de demostración. | Media |
| RNF-10 | Rendimiento | Los listados de solicitudes deben paginarse. | Media |
| RNF-11 | Disponibilidad | La aplicación debe estar accesible desde Internet o desde una infraestructura de demostración durante el periodo de evaluación. | Alta |
| RNF-12 | Disponibilidad | Ante un fallo, el sistema debe mostrar mensajes de error comprensibles sin exponer detalles técnicos. | Media |
| RNF-13 | Calidad | El backend debe seguir una arquitectura por capas (controladores, servicios, DTO y acceso a datos). | Alta |
| RNF-14 | Calidad | El sistema debe contar con pruebas automatizadas unitarias y de integración ejecutadas en el pipeline CI/CD. | Alta |
| RNF-15 | Calidad | El sistema debe generar logs y métricas que permitan identificar incidentes y depurar errores. | Media |
| RNF-16 | Integridad | El servidor debe garantizar que no existan dos reservas activas solapadas para un mismo espacio, incluso con solicitudes concurrentes. | Alta |
| RNF-17 | Seguridad | Un usuario solo accede a sus reservas; el supervisor a las de los espacios de su área; el administrador a todas. | Alta |
| RNF-18 | Rendimiento | La consulta de disponibilidad de un espacio y día debe responder en menos de 2 segundos con la carga de demostración. | Media |
| RNF-19 | Seguridad | Las evidencias se guardan fuera de la base de datos en un almacenamiento privado (Supabase Storage en la nube) y solo se entregan a usuarios autorizados mediante URLs firmadas de corta duración. | Alta |
