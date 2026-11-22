extends Node
## scene_game.tscn — escena principal (sección 15.2): muestra la pantalla de
## inicio, arranca el test inicial de preguntas y luego carga el pueblo. Contiene el mundo actual (pueblo o interior), la
## interfaz (HUD, diálogo, mostrador, mesa, cápsula, síntomas, resumen) y el
## fundido a negro de las puertas.

const ESCENA_MENU := preload("res://Scenes/UI/MenuInicio.tscn")
const ESCENA_TEST := preload("res://Scenes/Test/Test.tscn")
const RUTA_PUEBLO := "res://Scenes/World/Pueblo.tscn"
const DURACION_FUNDIDO := 0.35

@onready var mundo: Node2D = $Mundo
@onready var hud: CanvasLayer = $HUD
@onready var sintomas = $Sintomas
@onready var resumen = $Resumen
@onready var negro: ColorRect = $Fundido/Negro

var _cambiando := false


func _ready() -> void:
	GameState.cambio_escena_solicitado.connect(cambiar_escena)
	GameState.juego_terminado.connect(_on_juego_terminado)
	resumen.jugar_de_nuevo.connect(_on_jugar_de_nuevo)
	resumen.salir.connect(_on_salir)
	hud.hide()
	sintomas.habilitado = false
	negro.modulate.a = 0.0
	_mostrar_menu()


func _mostrar_menu() -> void:
	var menu = ESCENA_MENU.instantiate()
	add_child(menu)
	menu.jugar.connect(_on_jugar.bind(menu), CONNECT_ONE_SHOT)


## Pantalla de inicio → test inicial de preguntas (reemplaza al video).
func _on_jugar(menu: Node) -> void:
	await _fundir(1.0)
	menu.queue_free()
	var test = ESCENA_TEST.instantiate()
	add_child(test)
	test.terminado.connect(_on_test_terminado.bind(test), CONNECT_ONE_SHOT)
	await _fundir(0.0)


func _on_test_terminado(_buenas: int, _malas: int, test: Node) -> void:
	GameState.reiniciar()
	await _fundir(1.0)
	test.queue_free()
	hud.show()
	sintomas.habilitado = true
	await cambiar_escena(RUTA_PUEBLO, Vector2.INF)
	# Secuencia de pistas al iniciar el juego.
	await UI.dialogo().mostrar("Guía", Dialogos.TUTORIAL)


## Fundido a negro, cambio de escena y fundido de vuelta (mecánica 2).
func cambiar_escena(ruta: String, posicion_salida: Vector2) -> void:
	if _cambiando:
		return
	_cambiando = true
	GameState.bloquear()
	await _fundir(1.0)
	for hijo in mundo.get_children():
		mundo.remove_child(hijo)
		hijo.queue_free()
	GameState.posicion_entrada = posicion_salida
	var escena := (load(ruta) as PackedScene).instantiate()
	mundo.add_child(escena)
	await _fundir(0.0)
	GameState.desbloquear()
	_cambiando = false


func _fundir(alfa: float) -> void:
	var tween := create_tween()
	tween.tween_property(negro, "modulate:a", alfa, DURACION_FUNDIDO)
	await tween.finished


## Final único: la red queda funcionando (sección 13).
func _on_juego_terminado() -> void:
	sintomas.habilitado = false
	await _fundir(1.0)
	hud.hide()
	resumen.mostrar()
	await _fundir(0.0)


## Pantalla final → «Jugar de nuevo»: partida nueva desde la entrada del
## pueblo (A4), con todo en cero. No repite el test inicial ni la Guía.
func _on_jugar_de_nuevo() -> void:
	await _fundir(1.0)
	resumen.ocultar()
	GameState.reiniciar()
	hud.show()
	sintomas.habilitado = true
	await cambiar_escena(RUTA_PUEBLO, Vector2.INF)


## Pantalla final → «Salir del juego». En la web no se puede cerrar la
## pestaña: se vuelve a la pantalla de inicio.
func _on_salir() -> void:
	await _fundir(1.0)
	if not OS.has_feature("web"):
		get_tree().quit()
		return
	resumen.ocultar()
	for hijo in mundo.get_children():
		mundo.remove_child(hijo)
		hijo.queue_free()
	GameState.reiniciar()
	_mostrar_menu()
	await _fundir(0.0)
