extends StaticBody2D
## Personaje del pueblo (sección 5). La lógica de cada decisión sigue la
## sección 11 y la mecánica 5: la opción correcta entrega la pieza o suma una
## ayuda; la incorrecta no la entrega y muestra una cápsula que explica por
## qué; el jugador puede volver a hablar y decidir de nuevo.

## Id del personaje: luz, jorge, hernan, sofia, pedro, marta o camilo.
@export var personaje: StringName

var _ocupado := false

@onready var sprite: Sprite2D = $Sprite
@onready var etiqueta: Label = $Nombre

## Tamaño de un cuadro en Assets/Characters/personajes.png: 16 personajes en
## 4 columnas × 4 grupos; cada uno tiene 3 cuadros × 4 direcciones.
const CUADRO := Vector2(18, 26)


func _ready() -> void:
	add_to_group(StringName("npc_%s" % personaje))
	var d: Dictionary = Dialogos.PERSONAJES.get(personaje, {})
	var k: int = d.get("sprite", 0)
	var origen := Vector2((k % 4) * 3 + 1, (k / 4) * 4) * CUADRO  # cuadro de frente
	sprite.region_rect = Rect2(origen, CUADRO)
	etiqueta.text = d.get("nombre", "")


func texto_accion() -> String:
	return "Hablar con %s" % _datos().nombre


func interactuar() -> void:
	if _ocupado:
		return
	_ocupado = true
	match personaje:
		&"luz":
			await _decision_con_pieza(&"kit_ponchado", true)
		&"hernan":
			await _decision_con_pieza(&"punto_acceso", false)
		&"jorge":
			await _jorge()
		&"sofia", &"pedro":
			await _decision_ayuda()
		&"marta":
			await _marta()
		&"camilo":
			await _camilo()
	_ocupado = false


func _datos() -> Dictionary:
	return Dialogos.PERSONAJES[personaje]


func _decir(lineas: Array, opciones: Array = []) -> int:
	return await UI.dialogo().mostrar(_datos().nombre, lineas, opciones)


## Entrega una pieza necesaria con su cápsula. Si el inventario está lleno,
## no la entrega (el personaje la guarda para cuando vuelva).
func _entregar(id: StringName) -> bool:
	if not GameState.agregar_al_inventario(id):
		await _decir([Dialogos.INVENTARIO_LLENO])
		return false
	GameState.marcar_tomado(id)
	await _decir(_datos().entrega)
	await UI.capsula().mostrar(GameState.obtener_pieza(id).capsula)
	return true


func _bandera_convencido() -> StringName:
	return StringName("convencido_%s" % personaje)


## Doña Luz (kit + ayuda) y Don Hernán (punto de acceso).
func _decision_con_pieza(pieza_id: StringName, suma_ayuda: bool) -> void:
	var d := _datos()
	if GameState.fue_tomado(pieza_id):
		await _decir(d.despues)
		return
	if GameState.get_bandera(_bandera_convencido()):
		await _entregar(pieza_id)  # ya eligió (b) pero no tenía espacio
		return
	var r: int = await _decir(d.saludo, d.opciones)
	if r == 1:
		await _decir(d.respuesta_b)
		GameState.set_bandera(_bandera_convencido())
		if suma_ayuda:
			GameState.sumar_ayuda(personaje)
		await _entregar(pieza_id)
	else:
		await _decir(d.respuesta_a)
		await UI.capsula().mostrar(d.capsula_a)


## Don Jorge: (a) aceptar el multitoma (trampa: entra al inventario sin
## explicación, la pista solo aparece en el aula); (b) obtiene el regulador.
func _jorge() -> void:
	var d := _datos()
	if GameState.fue_tomado(&"regulador"):
		await _decir(d.despues)
		return
	if GameState.get_bandera(_bandera_convencido()):
		await _entregar(&"regulador")
		return
	var r: int = await _decir(d.saludo, d.opciones)
	if r == 1:
		await _decir(d.respuesta_b)
		GameState.set_bandera(_bandera_convencido())
		await _entregar(&"regulador")
	elif GameState.fue_tomado(&"multitoma"):
		await _decir(d.ya_multitoma)
	elif GameState.agregar_al_inventario(&"multitoma"):
		GameState.marcar_tomado(&"multitoma")
		await _decir(d.respuesta_a)
	else:
		await _decir([Dialogos.INVENTARIO_LLENO])


## Sofía, Don Pedro y Marta: (b) suma una ayuda con su cápsula.
func _decision_ayuda() -> void:
	var d := _datos()
	if GameState.ya_ayudo(personaje):
		await _decir(d.despues)
		return
	var r: int = await _decir(d.saludo, d.opciones)
	if r == 1:
		await _decir(d.respuesta_b)
		GameState.sumar_ayuda(personaje)
		await UI.capsula().mostrar(d.capsula_b)
	else:
		await _decir(d.respuesta_a)
		await UI.capsula().mostrar(d.capsula_a)


func _marta() -> void:
	if not GameState.ya_ayudo(&"marta"):
		await _decision_ayuda()
	elif not GameState.sintomas_desbloqueados:
		await _decir(_datos().despues_sin_sintomas)
	else:
		await _decir(_datos().despues)


## Camilo ofrece lo que tiene y no aconseja.
func _camilo() -> void:
	await _decir(_datos().saludo)
	await UI.mostrador().abrir("Mostrador de Camilo", Dialogos.MOSTRADOR_TIENDA)
