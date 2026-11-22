extends CharacterBody2D
## Técnico de apoyo del municipio (sección 15): CharacterBody2D con movimiento
## en 4 direcciones y move_and_slide. Los sprites y animaciones están en
## PackPlayerTecnico/. El botón de acción frente a un personaje, un mostrador,
## un objeto o una puerta llama a su método interactuar().

const VELOCIDAD := 64.0
const NOMBRES := {
	Vector2.DOWN: "abajo", Vector2.LEFT: "izquierda",
	Vector2.RIGHT: "derecha", Vector2.UP: "arriba",
}

var direccion := Vector2.DOWN

@onready var interactor: Area2D = $Interactor
@onready var sprite: AnimatedSprite2D = $Sprite


func _physics_process(_delta: float) -> void:
	if GameState.entrada_bloqueada():
		velocity = Vector2.ZERO
		_animar(false)
		GameState.set_aviso_accion("")
		return
	var x := Input.get_axis("mover_izquierda", "mover_derecha")
	var y := Input.get_axis("mover_arriba", "mover_abajo")
	var mov := Vector2.ZERO
	# Solo 4 direcciones: si se pulsan dos ejes, gana el horizontal.
	if not is_zero_approx(x):
		mov.x = signf(x)
	elif not is_zero_approx(y):
		mov.y = signf(y)
	if mov != Vector2.ZERO:
		direccion = mov
		interactor.position = direccion * 10.0 + Vector2(0, 2)
	velocity = mov * VELOCIDAD
	move_and_slide()
	_animar(mov != Vector2.ZERO)
	_actualizar_aviso()


## Muestra qué tecla usar frente a lo que tiene delante («[E] Hablar con Marta»).
func _actualizar_aviso() -> void:
	var objetivo = _buscar_objetivo()
	if objetivo and objetivo.has_method("texto_accion"):
		GameState.set_aviso_accion("[E] / [Espacio]  " + objetivo.texto_accion())
	else:
		GameState.set_aviso_accion("")


func _animar(caminando: bool) -> void:
	var nombre := ("caminar_" if caminando else "quieto_") + str(NOMBRES[direccion])
	if sprite.animation != nombre:
		sprite.play(nombre)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("accion") or GameState.entrada_bloqueada():
		return
	var objetivo = _buscar_objetivo()
	if objetivo:
		get_viewport().set_input_as_handled()
		objetivo.interactuar()


## Devuelve el elemento interactivo más cercano delante del jugador.
func _buscar_objetivo() -> Node:
	var mejor: Node = null
	var mejor_dist := INF
	for area in interactor.get_overlapping_areas():
		var nodo: Node = area if area.has_method("interactuar") else area.get_parent()
		if nodo == null or not nodo.has_method("interactuar"):
			continue
		var d := area.global_position.distance_to(interactor.global_position)
		if d < mejor_dist:
			mejor_dist = d
			mejor = nodo
	return mejor
