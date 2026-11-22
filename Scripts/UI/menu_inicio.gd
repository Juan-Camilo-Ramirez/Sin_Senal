extends CanvasLayer
## Pantalla de inicio: lo primero que ve el jugador. «Jugar» pasa al test
## inicial de preguntas; «Cómo jugar» muestra el objetivo y los controles.

signal jugar

@onready var fondo: TextureRect = $Fondo
@onready var botones: VBoxContainer = $Botones
@onready var boton_jugar: Button = $Botones/Jugar
@onready var boton_como: Button = $Botones/ComoJugar
@onready var boton_salir: Button = $Botones/Salir
@onready var panel_como: Panel = $PanelComo
@onready var boton_volver: Button = $PanelComo/Volver
@onready var tecnico: AnimatedSprite2D = $Tecnico

var _hecho := false


func _ready() -> void:
	boton_jugar.pressed.connect(_on_jugar)
	boton_como.pressed.connect(_mostrar_como.bind(true))
	boton_volver.pressed.connect(_mostrar_como.bind(false))
	boton_salir.pressed.connect(func(): get_tree().quit())
	boton_salir.visible = not OS.has_feature("web")  # en la web no se cierra la pestaña
	panel_como.hide()
	tecnico.play("caminar_abajo")
	boton_jugar.grab_focus()
	# Paneo lento del mapa del pueblo de fondo.
	var tween := create_tween().set_loops()
	tween.tween_property(fondo, "position:x", -180.0, 18.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(fondo, "position:x", 0.0, 18.0).set_trans(Tween.TRANS_SINE)


func _mostrar_como(mostrar: bool) -> void:
	panel_como.visible = mostrar
	botones.visible = not mostrar
	if mostrar:
		boton_volver.grab_focus()
	else:
		boton_como.grab_focus()


func _on_jugar() -> void:
	if _hecho:
		return
	_hecho = true
	jugar.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accion"):
		UI.pulsar_foco(get_viewport(), botones if botones.visible else panel_como)
	elif event.is_action_pressed("ui_cancel") and panel_como.visible:
		get_viewport().set_input_as_handled()
		_mostrar_como(false)
