class_name Dialogos
extends RefCounted
## Todos los textos de diálogo del juego en un solo lugar.
## - Las opciones (a)/(b) son las de la sección 11, tal cual.
## - Lo marcado [PROVISIONAL] no viene en el documento: son textos de relleno
##   para revisar y reemplazar (saludos, respuestas y cápsulas de las opciones
##   incorrectas, explicaciones de orden, mensaje final).

const INVENTARIO_LLENO := "Tu inventario está lleno (6/6). Instala piezas en la mesa del aula y vuelve por esta."  # [PROVISIONAL]

# ------------------------------------------------------------ Personajes
# Cada uno: nombre, saludo, opciones, respuesta_b, respuesta_a, capsula_a,
# capsula_b (solo ayudas), entrega, despues.

const PERSONAJES := {
	# Casa de la junta (Doña Luz) — (b) obtiene el kit y suma una ayuda.
	&"luz": {
		"nombre": "Doña Luz",
		"sprite": 12,  # índice en Assets/Characters/personajes.png
		"saludo": ["Buenas. Soy Doña Luz, de la junta de acción comunal.",
			"La junta tiene un kit de ponchado. Se lo presto si me explica para qué sirve la red."],  # [PROVISIONAL]
		"opciones": ["(a) decir que no tiene tiempo", "(b) explicarle brevemente"],
		"respuesta_b": ["Técnico: La red conecta los computadores del aula a internet. Así la profesora Marta puede dar sus clases virtuales y la escuela vuelve a estar conectada.",
			"Doña Luz: Ah, entonces es para los muchachos de toda la vereda. Lléveselo."],  # [PROVISIONAL]
		"respuesta_a": ["Doña Luz: Si no tiene tiempo de explicarme, tampoco le puedo prestar las herramientas de la comunidad."],  # [PROVISIONAL]
		"capsula_a": "Doña Luz presta las herramientas de la comunidad a cambio de entender el proyecto. Sin explicación no hay kit. Puedes volver a hablar con ella.",  # [PROVISIONAL]
		"entrega": ["Doña Luz te entrega el kit de ponchado (crimpadora y probador de cables)."],
		"despues": ["Doña Luz: Cuide el kit, que es de toda la vereda."],  # [PROVISIONAL]
	},
	# Taller de electricidad (Don Jorge) — (b) obtiene el regulador.
	&"jorge": {
		"nombre": "Don Jorge",
		"sprite": 15,  # índice en Assets/Characters/personajes.png
		"saludo": ["Buenas, soy Don Jorge, el electricista.",
			"¿Es para el router de la escuela? Llévese este multitoma, ahí conecta todo."],  # [PROVISIONAL]
		"opciones": ["(a) aceptarlo", "(b) explicar que no protege contra sobretensión y pedir el regulador"],
		"respuesta_b": ["Técnico: Un multitoma solo reparte la corriente; no protege contra sobretensión. Necesito el regulador de voltaje.",
			"Don Jorge: Tiene razón. Tenga el regulador."],  # [PROVISIONAL]
		"respuesta_a": ["Don Jorge: Aquí tiene el multitoma."],  # [PROVISIONAL]
		"ya_multitoma": ["Don Jorge: Ya le di el multitoma."],  # [PROVISIONAL]
		"entrega": ["Don Jorge te entrega el regulador de voltaje."],
		"despues": ["Don Jorge: Con ese regulador el router queda protegido."],  # [PROVISIONAL]
	},
	# Oficina del rector (Don Hernán) — (b) obtiene el punto de acceso.
	&"hernan": {
		"nombre": "Don Hernán",
		"sprite": 9,  # índice en Assets/Characters/personajes.png
		"saludo": ["Gracias por venir. Guardo un punto de acceso de un proyecto anterior...",
			"...pero me da miedo que se dañe."],  # [PROVISIONAL]
		"opciones": ["(a) llevárselo sin explicar", "(b) explicarle para qué se usa"],
		"respuesta_b": ["Técnico: El punto de acceso crea la red wifi para que la señal llegue al patio. Se conecta por cable a la red de la escuela.",
			"Don Hernán: Entonces sí lo necesitamos. Llévelo."],  # [PROVISIONAL]
		"respuesta_a": ["Don Hernán: Espere, no se lo puede llevar así, sin decirme para qué es."],  # [PROVISIONAL]
		"capsula_a": "Don Hernán teme que el equipo se dañe. Si no le explicas para qué se usa, no lo entrega. Puedes volver a hablar con él.",  # [PROVISIONAL]
		"entrega": ["Don Hernán te entrega el punto de acceso."],
		"despues": ["Don Hernán: Cuídelo mucho, por favor."],  # [PROVISIONAL]
	},
	# Plaza (Sofía) — (b) suma una ayuda.
	&"sofia": {
		"nombre": "Sofía",
		"sprite": 10,  # índice en Assets/Characters/personajes.png
		"saludo": ["Sin internet en la escuela no puedo hacer las tareas ni ver los videos de clase.",
			"Oiga, ¿por qué el cable tiene colores?"],  # [PROVISIONAL]
		"opciones": ["(a) ignorarla", "(b) mostrarle el orden de los pares"],
		"respuesta_b": ["Técnico: Mira: son 4 pares trenzados. Cada color va con su blanco, y el orden debe ser el mismo en las dos puntas.",
			"Sofía: ¡Ahora entiendo!"],  # [PROVISIONAL]
		"respuesta_a": ["Sofía se queda sin respuesta."],  # [PROVISIONAL]
		"capsula_b": "Los colores identifican los 4 pares del cable UTP. Si el orden es el mismo en los dos conectores, cada hilo llega a su pareja.",  # [PROVISIONAL]
		"capsula_a": "Explicar lo que haces también es parte del trabajo del técnico. Puedes volver a hablar con Sofía.",  # [PROVISIONAL]
		"despues": ["Sofía: ¡Ya me sé el orden de los pares!"],  # [PROVISIONAL]
	},
	# Plaza (Don Pedro) — (b) suma una ayuda.
	&"pedro": {
		"nombre": "Don Pedro",
		"sprite": 8,  # índice en Assets/Characters/personajes.png
		"saludo": ["Buenas, joven. ¿Ese internet me servirá para ver los precios de mi cosecha?"],  # [PROVISIONAL]
		"opciones": ["(a) decir que sí sin más", "(b) explicar que depende de la conexión de la escuela y de quién pueda usarla"],
		"respuesta_b": ["Don Pedro: Ah, entonces hay que hablar con la escuela y la junta. Gracias por explicarme."],  # [PROVISIONAL]
		"respuesta_a": ["Don Pedro: ¡Qué bueno! Mañana mismo voy a la escuela."],  # [PROVISIONAL]
		"capsula_b": "El acceso a internet en la vereda depende de la conexión de la escuela y de los acuerdos sobre quién puede usarla.",  # [PROVISIONAL]
		"capsula_a": "Un «sí» sin explicación crea falsas expectativas: el uso depende de la conexión de la escuela y de quién pueda usarla. Puedes volver a hablar con Don Pedro.",  # [PROVISIONAL]
		"despues": ["Don Pedro: Voy a hablar con Doña Luz sobre el horario de uso."],  # [PROVISIONAL]
	},
	# Aula de sistemas (Marta) — (b) suma una ayuda.
	&"marta": {
		"nombre": "Marta",
		"sprite": 11,  # índice en Assets/Characters/personajes.png
		"saludo": ["¡Qué bueno que llegó! Hoy tengo la clase virtual con la secretaría de educación.",
			"No entiendo las luces del router y del switch."],  # [PROVISIONAL]
		"opciones": ["(a) decirle que no se preocupe", "(b) explicarle qué significa cada luz"],
		"respuesta_b": ["Marta: ¡Ah, ya entiendo! Así sabré cuándo algo falla."],  # [PROVISIONAL]
		"respuesta_a": ["Marta: Bueno... pero si algo falla no sabré qué mirar."],  # [PROVISIONAL]
		"capsula_b": "Luz de encendido: el equipo tiene energía. Luz de enlace fija: hay un cable conectado. Luz que parpadea: pasan datos. Si un puerto no prende, revisa el cable.",  # [PROVISIONAL]
		"capsula_a": "Explicar las luces ayuda a que la escuela detecte fallas por su cuenta. Puedes volver a hablar con Marta.",  # [PROVISIONAL]
		"despues_sin_sintomas": ["Marta: Revise los equipos del aula, al fondo, para ver qué se dañó."],  # [PROVISIONAL]
		"despues": ["Marta: Cuando tenga las piezas, use la mesa de instalación."],  # [PROVISIONAL]
	},
	# Tienda (Camilo) — ofrece lo que tiene y no aconseja.
	&"camilo": {
		"nombre": "Camilo",
		"sprite": 14,  # índice en Assets/Characters/personajes.png
		"saludo": ["Buenas, soy Camilo. Esto es lo que tengo: usted verá qué le sirve."],  # [PROVISIONAL]
	},
}

# ------------------------------------------------------------ Mostradores

## Tienda: cinco objetos (sección 11). Camilo no da pistas.
const MOSTRADOR_TIENDA := [
	{"id": &"conectores_rj11", "texto": "Conectores RJ11"},
	{"id": &"conectores_rj45", "texto": "Conectores RJ45"},
	{"id": &"cable_coaxial", "texto": "Cable coaxial"},
	{"id": &"fuente_voltaje", "texto": "Fuente de voltaje"},
	{"id": &"router_domestico", "texto": "Router doméstico barato"},
]

## Estantería del depósito: switch golpeado, hub viejo y rollo de cable UTP.
const ESTANTERIA_DEPOSITO := [
	{"id": &"switch", "texto": "Switch golpeado", "probar": true},
	{"id": &"hub_viejo", "texto": "Hub viejo"},
	{"id": &"cable_utp", "texto": "Rollo de cable (etiqueta: UTP Cat5e)"},
]
const SWITCH_SIN_PROBAR := "Está golpeado: hay que probarlo en un tomacorriente antes de cargarlo."
const SWITCH_PROBADO := "Lo conectas al tomacorriente... ¡Enciende! Es válido."  # [PROVISIONAL]

# ------------------------------------------------------------ Aula

const EQUIPOS := ["Revisas los equipos del aula de sistemas.",
	"Anotas lo que encuentras en la lista de síntomas.",
	"Lista de síntomas desbloqueada. Pulsa Tab para consultarla en cualquier momento."]  # [PROVISIONAL]

## Marta explica por qué va antes el paso actual (mecánica 10). [PROVISIONAL]
const FUERA_DE_ORDEN := {
	&"regulador": "Primero hay que conectar el regulador al router: sin energía estable nada funciona, y un pico de voltaje podría volver a dañar los equipos.",
	&"switch": "Antes hay que colocar el switch: es el que reparte la conexión hacia el cable y los computadores.",
	&"ponchar": "Primero hay que ponchar el cable con los conectores RJ45 y la crimpadora: sin conectores, el cable no se puede probar ni conectar.",
	&"probar": "Antes de conectar el punto de acceso hay que probar el cable: si un hilo no hace contacto, el wifi tampoco funcionará.",
	&"punto_acceso": "Falta conectar el punto de acceso antes de la prueba final.",
}

const MESA_ELEGIR_PIEZA := "Elige una pieza de tu inventario y luego el lugar de la mesa donde va."  # [PROVISIONAL]
const MESA_INSTALADA := "Instalaste: %s."  # [PROVISIONAL]
const MESA_PONCHAR_FALTA := "Para ponchar faltan: %s."  # [PROVISIONAL]
const MESA_TRAMPA := "%s: %s\nPista: %s\n(La pieza se retira del inventario.)"
const MESA_PROBADO := "El probador marca los 8 hilos en orden: cada hilo hace contacto."  # [PROVISIONAL]
const MESA_YA_PROBADO := "El cable ya fue probado."  # [PROVISIONAL]
const MESA_FINAL := "Prueba final: el router, el switch y el punto de acceso encienden. ¡La red funciona!"  # [PROVISIONAL]

# ------------------------------------------------------------ Guía inicial

## Secuencia de pistas al empezar la partida (antes de mover al técnico).
const TUTORIAL := [
	"Eres el técnico de apoyo del municipio. Anoche un rayo dejó sin internet a la escuela La Esperanza.",
	"Muévete con las flechas o con W, A, S y D.",
	"Cuando estés frente a una persona, una puerta o un objeto, abajo aparecerá un aviso. Pulsa E o Espacio para interactuar.",
	"Arriba ves las piezas encontradas (0/6), las personas ayudadas (0/4) y tu inventario de 6 espacios.",
	"Debajo verás siempre tu objetivo: te dirá qué hacer paso a paso.",
	"La escuela está en 3 casas seguidas sobre el camino de arriba: el depósito, la oficina del rector y la sala de sistemas (la de la bandera azul).",
	"Primer paso: entra a la sala de sistemas y revisa los equipos dañados.",
]

# ------------------------------------------------------------ Final

const CIERRE := "La escuela vuelve a tener internet. Marta se conecta a su clase virtual."
const MENSAJE_FINAL := "Una escuela rural conectada y protegida contra los picos de voltaje mantiene abiertas las puertas del aprendizaje para toda la vereda."  # [PROVISIONAL]

# ------------------------------------------------------------ Test inicial
# Reemplaza al video de introducción. Primero se muestra la llamada de Don
# Hernán y luego 8 preguntas sobre los ítems del juego. Cada pregunta: texto,
# opciones, indice de la correcta (en el orden escrito aquí; el test las
# mezcla al mostrarlas) y retroalimentación.

const LLAMADA_DON_HERNAN := "Don Hernán: \"Buenos días. Anoche cayó un rayo y nos quedamos sin internet. La profesora Marta tiene hoy una clase virtual. ¿Podría venir a echar un vistazo al daño para ver cómo lo solucionamos?\""
const TEST_INTRO := "Antes de salir hacia la escuela, responde 8 preguntas sobre los equipos que vas a encontrar. No hay castigo: con cualquier puntaje empiezas a jugar."

const TEST_PREGUNTAS := [
	{
		"pregunta": "Cayó un rayo y quemó el router. ¿Qué equipo protege a los aparatos de los picos de voltaje?",
		"opciones": ["Una multitoma", "Un regulador de voltaje", "Una fuente de voltaje cualquiera"],
		"correcta": 1,
		"explicacion": "El regulador protege los equipos de picos de voltaje. La multitoma solo reparte la corriente.",
	},
	{
		"pregunta": "En una sala con varios computadores, ¿qué equipo envía el tráfico solo al equipo que le corresponde?",
		"opciones": ["Un hub", "Un switch", "Un cable coaxial"],
		"correcta": 1,
		"explicacion": "El switch reparte la conexión entre los equipos de una misma red. El hub repite el tráfico a todos los puertos y satura la red.",
	},
	{
		"pregunta": "¿Qué cable se usa para una red de computadores?",
		"opciones": ["Cable UTP Cat5e, con 4 pares trenzados de cobre", "Cable coaxial, con un solo conductor central", "Cable telefónico de 2 hilos"],
		"correcta": 0,
		"explicacion": "El UTP tiene 4 pares trenzados de cobre. El coaxial lleva señal de televisión por un solo conductor.",
	},
	{
		"pregunta": "¿Qué conector va en las puntas de un cable de red?",
		"opciones": ["RJ11, de 4 a 6 pines", "RJ45, de 8 pines", "Un conector de antena"],
		"correcta": 1,
		"explicacion": "El RJ45 es más ancho y tiene 8 pines. El RJ11 es de teléfono y no encaja en un puerto de red.",
	},
	{
		"pregunta": "¿Para qué sirven la crimpadora y el probador de cables?",
		"opciones": ["Para medir el voltaje del tomacorriente", "La crimpadora fija el conector al cable y el probador confirma que cada hilo hace contacto", "Para configurar la contraseña del wifi"],
		"correcta": 1,
		"explicacion": "Con la crimpadora se poncha el cable con sus conectores; con el probador se revisa hilo por hilo.",
	},
	{
		"pregunta": "El router de la escuela todavía funciona, pero no hay wifi en el aula. ¿Qué hace falta?",
		"opciones": ["Comprar un router doméstico barato", "Un punto de acceso, que crea la red wifi y se conecta por cable", "Una fuente de voltaje más potente"],
		"correcta": 1,
		"explicacion": "Cambiar el router no resuelve el problema. El punto de acceso crea el wifi y se conecta por cable a la red.",
	},
	{
		"pregunta": "El router se quedó sin energía. ¿Qué puede pasar si lo conectas a una fuente de voltaje distinta a la suya?",
		"opciones": ["Funciona más rápido", "No pasa nada, cualquier fuente sirve", "Se puede quemar"],
		"correcta": 2,
		"explicacion": "Un voltaje distinto al del router puede quemarlo. Para protegerlo de picos de voltaje se usa un regulador.",
	},
	{
		"pregunta": "Ya ponchaste el cable UTP con los conectores RJ45. ¿Qué debes hacer antes de conectar el punto de acceso?",
		"opciones": ["Comprar un router nuevo", "Probar el cable con el probador", "Conectar una multitoma"],
		"correcta": 1,
		"explicacion": "El cable se prueba antes de conectar el punto de acceso: si un hilo falla, el wifi no funcionará.",
	},
]
