extends CanvasLayer
## Cuadro de cápsula emergente (sección 14): concepto corto después de cada
## decisión. Las cápsulas se muestran de una en una.

signal cerrada
signal _cerrar

@onready var fondo: ColorRect = $Fondo
@onready var texto: Label = $Fondo/Panel/Texto
@onready var continuar: Button = $Fondo/Panel/Continuar

var _abierta := false


func _ready() -> void:
	add_to_group(&"ui_capsula")
	fondo.hide()
	continuar.pressed.connect(func(): _cerrar.emit())
	GameState.capsula_solicitada.connect(func(t: String): mostrar(t))


func mostrar(contenido: String) -> void:
	if contenido.is_empty():
		return
	while _abierta:
		await cerrada
	_abierta = true
	GameState.bloquear()
	texto.text = contenido
	fondo.show()
	continuar.grab_focus()
	await _cerrar
	fondo.hide()
	await get_tree().process_frame
	_abierta = false
	GameState.desbloquear()
	cerrada.emit()


func _input(event: InputEvent) -> void:
	if not fondo.visible:
		return
	if event.is_action_pressed("accion") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar.emit()
