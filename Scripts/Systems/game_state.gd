extends Node
## GameState (autoload). Sección 15 «Sistemas»: inventario de 6 espacios,
## piezas instaladas, ayudas y banderas (síntomas desbloqueados, paso de
## instalación). Regla 12.1: no hay tiempo, vidas ni contador de errores,
## así que aquí no existe ninguna de esas variables.

# --- Señales que escucha la interfaz (HUD, inventario, cápsula) ---
signal inventario_cambiado
signal piezas_encontradas_cambiadas(cantidad: int)
signal ayudas_cambiadas(cantidad: int)
signal sintomas_desbloqueados_cambiado
signal paso_instalacion_cambiado(indice: int)
signal capsula_solicitada(texto: String)
signal cambio_escena_solicitado(ruta: String, posicion_salida: Vector2)
signal juego_terminado
signal banderas_cambiadas
signal aviso_accion_cambiado(texto: String)

const MAX_INVENTARIO := 6   # Regla 12.2 / Decisión cerrada 3
const TOTAL_PIEZAS := 6     # Contador 0/6
const TOTAL_AYUDAS := 4     # Contador 0/4

## Orden de instalación (sección 9.8, pasos a–f).
const ORDEN_INSTALACION := [
	&"regulador",     # a. Conectar el regulador al router.
	&"switch",        # b. Colocar el switch.
	&"ponchar",       # c. Ponchar el cable con los conectores y la crimpadora.
	&"probar",        # d. Probar el cable con el probador.
	&"punto_acceso",  # e. Conectar el punto de acceso.
	&"prueba_final",  # f. Prueba final de conexión.
]

const NOMBRES_PASOS := {
	&"regulador": "Conectar el regulador al router",
	&"switch": "Colocar el switch",
	&"ponchar": "Ponchar el cable con los conectores y la crimpadora",
	&"probar": "Probar el cable con el probador",
	&"punto_acceso": "Conectar el punto de acceso",
	&"prueba_final": "Prueba final de conexión",
}

## Sistema de diagnóstico (sección 7).
const SINTOMAS := [
	{"sintoma": "El router no enciende", "causa": "Se quemó el regulador que lo alimentaba", "pieza": "Regulador de voltaje"},
	{"sintoma": "Los computadores del aula no reciben red", "causa": "El switch dejó de repartir la conexión", "pieza": "Switch"},
	{"sintoma": "El wifi no llega al patio", "causa": "El punto de acceso dejó de funcionar", "pieza": "Punto de acceso"},
	{"sintoma": "El cable hacia el aula está quemado", "causa": "Tramo de cable dañado", "pieza": "Cable UTP"},
	{"sintoma": "El cable nuevo no conecta aunque parece bien", "causa": "Faltan conectores o están mal hechos", "pieza": "Conectores RJ45"},
	{"sintoma": "No se puede ponchar ni probar el cable", "causa": "Faltan herramientas", "pieza": "Kit de ponchado (crimpadora y probador)"},
]

## Catálogo: las 6 piezas necesarias y las 6 trampas (secciones 8.1 y 8.2).
## Se cargan con preload para que funcionen también en la exportación web.
const _RECURSOS_PIEZAS := [
	preload("res://Assets/Items/Piezas/regulador.tres"),
	preload("res://Assets/Items/Piezas/switch.tres"),
	preload("res://Assets/Items/Piezas/punto_acceso.tres"),
	preload("res://Assets/Items/Piezas/cable_utp.tres"),
	preload("res://Assets/Items/Piezas/conectores_rj45.tres"),
	preload("res://Assets/Items/Piezas/kit_ponchado.tres"),
	preload("res://Assets/Items/Piezas/cable_coaxial.tres"),
	preload("res://Assets/Items/Piezas/fuente_voltaje.tres"),
	preload("res://Assets/Items/Piezas/hub_viejo.tres"),
	preload("res://Assets/Items/Piezas/conectores_rj11.tres"),
	preload("res://Assets/Items/Piezas/multitoma.tres"),
	preload("res://Assets/Items/Piezas/router_domestico.tres"),
]

var catalogo: Dictionary = {}               # id -> PiezaData

# --- Estado de la partida ---
var inventario: Array[PiezaData] = []       # máximo MAX_INVENTARIO
var piezas_encontradas: Array[StringName] = []  # ids de piezas necesarias conseguidas (0/6)
var piezas_instaladas: Array[StringName] = []   # ids colocados en la mesa
var ayudas: Array[StringName] = []          # ids de las personas ayudadas (0/4)
var sintomas_desbloqueados := false         # bandera: lista de síntomas (9.7)
var paso_actual := 0                        # índice en ORDEN_INSTALACION
var banderas: Dictionary = {}               # banderas generales (diálogos, objetos tomados…)
var objetos_tomados: Array[StringName] = [] # objetos ya retirados de mostradores/personajes
var terminado := false                      # final único alcanzado

# --- Puertas (sección 15): posición de llegada a la próxima escena y punto
# donde reaparecer en el pueblo al salir de un interior.
var posicion_entrada := Vector2.INF
var posicion_regreso := Vector2.INF

var _bloqueos := 0  # ventanas abiertas o fundido en curso: el jugador no se mueve


func _ready() -> void:
	for recurso in _RECURSOS_PIEZAS:
		var pieza := recurso as PiezaData
		catalogo[pieza.id] = pieza
	assert(catalogo.size() == 12, "Deben existir 6 piezas necesarias y 6 trampas.")


## Deja todo como al empezar una partida nueva.
func reiniciar() -> void:
	inventario.clear()
	piezas_encontradas.clear()
	piezas_instaladas.clear()
	ayudas.clear()
	sintomas_desbloqueados = false
	paso_actual = 0
	banderas.clear()
	aviso_accion = ""
	objetos_tomados.clear()
	terminado = false
	posicion_entrada = Vector2.INF
	posicion_regreso = Vector2.INF
	_bloqueos = 0
	inventario_cambiado.emit()
	piezas_encontradas_cambiadas.emit(0)
	ayudas_cambiadas.emit(0)
	sintomas_desbloqueados_cambiado.emit()
	paso_instalacion_cambiado.emit(0)
	banderas_cambiadas.emit()
	aviso_accion_cambiado.emit("")  # que no quede el aviso de la partida anterior


# ---------------------------------------------------------------- Catálogo

func obtener_pieza(id: StringName) -> PiezaData:
	return catalogo.get(id)


func piezas_necesarias() -> Array[PiezaData]:
	var lista: Array[PiezaData] = []
	for pieza: PiezaData in catalogo.values():
		if pieza.necesaria:
			lista.append(pieza)
	return lista


func piezas_trampa() -> Array[PiezaData]:
	var lista: Array[PiezaData] = []
	for pieza: PiezaData in catalogo.values():
		if not pieza.necesaria:
			lista.append(pieza)
	return lista


# -------------------------------------------------------------- Inventario

func inventario_lleno() -> bool:
	return inventario.size() >= MAX_INVENTARIO


func espacios_libres() -> int:
	return MAX_INVENTARIO - inventario.size()


func tiene_en_inventario(id: StringName) -> bool:
	for pieza in inventario:
		if pieza.id == id:
			return true
	return false


## Agrega una pieza (necesaria o trampa: las dos ocupan espacio, 9.6).
## Devuelve false si el inventario está lleno.
func agregar_al_inventario(id: StringName) -> bool:
	var pieza := obtener_pieza(id)
	if pieza == null or inventario_lleno():
		return false
	inventario.append(pieza)
	if pieza.necesaria and not piezas_encontradas.has(id):
		piezas_encontradas.append(id)
		piezas_encontradas_cambiadas.emit(piezas_encontradas.size())
	inventario_cambiado.emit()
	return true


## Retira una pieza del inventario (pieza trampa rechazada o pieza instalada).
func quitar_del_inventario(id: StringName) -> void:
	for i in inventario.size():
		if inventario[i].id == id:
			inventario.remove_at(i)
			inventario_cambiado.emit()
			return


# ------------------------------------------------------------------ Ayudas

## Suma una ayuda una sola vez por persona (contador 0/4).
func sumar_ayuda(persona: StringName) -> void:
	if ayudas.has(persona):
		return
	ayudas.append(persona)
	ayudas_cambiadas.emit(ayudas.size())


func ya_ayudo(persona: StringName) -> bool:
	return ayudas.has(persona)


# ---------------------------------------------------------------- Síntomas

func desbloquear_sintomas() -> void:
	if sintomas_desbloqueados:
		return
	sintomas_desbloqueados = true
	sintomas_desbloqueados_cambiado.emit()


# -------------------------------------------------------------- Instalación

func paso_id_actual() -> StringName:
	if instalacion_completa():
		return &""
	return ORDEN_INSTALACION[paso_actual]


func indice_de_paso(paso: StringName) -> int:
	return ORDEN_INSTALACION.find(paso)


func avanzar_paso() -> void:
	if instalacion_completa():
		return
	paso_actual += 1
	paso_instalacion_cambiado.emit(paso_actual)


func marcar_instalada(id: StringName) -> void:
	if not piezas_instaladas.has(id):
		piezas_instaladas.append(id)


func esta_instalada(id: StringName) -> bool:
	return piezas_instaladas.has(id)


func instalacion_completa() -> bool:
	return paso_actual >= ORDEN_INSTALACION.size()


# ----------------------------------------------------------------- Banderas

func set_bandera(nombre: StringName, valor: Variant = true) -> void:
	if banderas.has(nombre) and typeof(banderas[nombre]) == typeof(valor) and banderas[nombre] == valor:
		return
	banderas[nombre] = valor
	banderas_cambiadas.emit()


func get_bandera(nombre: StringName, por_defecto: Variant = false) -> Variant:
	return banderas.get(nombre, por_defecto)


# ------------------------------------------------------------------ Cápsula

## Pide a la interfaz que muestre la cápsula emergente (sección 14).
func mostrar_capsula(texto: String) -> void:
	if texto.is_empty():
		return
	capsula_solicitada.emit(texto)


# --------------------------------------------------------- Objetos tomados

## Cada objeto se puede tomar una sola vez (mostradores y personajes).
func marcar_tomado(id: StringName) -> void:
	if not objetos_tomados.has(id):
		objetos_tomados.append(id)


func fue_tomado(id: StringName) -> bool:
	return objetos_tomados.has(id)


# ---------------------------------------------------- Bloqueo de la entrada

func bloquear() -> void:
	_bloqueos += 1


func desbloquear() -> void:
	_bloqueos = maxi(_bloqueos - 1, 0)


func entrada_bloqueada() -> bool:
	return _bloqueos > 0


# ------------------------------------------------------- Escenas y final

## Lo llama una Puerta: scene_game hace el fundido a negro y carga la escena.
func solicitar_cambio_escena(ruta: String, posicion_salida: Vector2) -> void:
	cambio_escena_solicitado.emit(ruta, posicion_salida)


## Final único: la red queda funcionando (sección 13).
func terminar_juego() -> void:
	if terminado:
		return
	terminado = true
	juego_terminado.emit()


# ------------------------------------------------- Aviso de interacción

var aviso_accion := ""


## Lo actualiza el jugador: qué pasa si pulsa la tecla de acción ahora.
func set_aviso_accion(texto: String) -> void:
	if texto == aviso_accion:
		return
	aviso_accion = texto
	aviso_accion_cambiado.emit(texto)


# -------------------------------------------------- Objetivo paso a paso

## Pista de lo que el jugador debe hacer ahora (secuencia del flujo de la
## sección 10). No revela qué piezas son trampas.
func objetivo_actual() -> String:
	if terminado:
		return ""
	if not sintomas_desbloqueados:
		if not get_bandera(&"visito_escuela"):
			return "Ve a la sala de sistemas: la casa de la bandera azul, arriba a la derecha del pueblo."
		return "En la sala de sistemas, revisa los equipos dañados para saber qué falló."
	if piezas_encontradas.size() < TOTAL_PIEZAS:
		if inventario_lleno():
			return "Inventario lleno: lleva las piezas a la mesa de instalación de la sala de sistemas."
		return "Consigue las piezas (%d/%d): depósito, oficina del rector, taller, tienda y casa de la junta. [Tab] síntomas." % [piezas_encontradas.size(), TOTAL_PIEZAS]
	if not instalacion_completa():
		var letras := ["a", "b", "c", "d", "e", "f"]
		return "En la sala de sistemas, usa la mesa de instalación. Paso %s: %s." % [letras[paso_actual], NOMBRES_PASOS[ORDEN_INSTALACION[paso_actual]]]
	return ""
