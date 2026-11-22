extends CanvasLayer
## Cuadro de diálogo: muestra las líneas de un personaje y, si las hay, las
## opciones de decisión (a)/(b) de la sección 11. Devuelve el índice elegido.

signal _avanzar
signal _elegida(indice: int)

@onready var panel: Panel = $Panel
@onready var nombre: Label = $Panel/Nombre
@onready var texto: Label = $Panel/Texto
@onready var opciones: VBoxContainer = $Panel/Opciones
@onready var aviso: Label = $Panel/Aviso

var _modo := 0  # 0 cerrado, 1 esperando avanzar, 2 eligiendo opción


func _ready() -> void:
	add_to_group(&"ui_dialogo")
	panel.hide()
	panel.gui_input.connect(_on_panel_gui_input)


## Muestra las líneas una por una. Si hay opciones, la última línea queda
## visible junto a ellas. Devuelve el índice de la opción (o -1).
func mostrar(quien: String, lineas: Array, lista_opciones: Array = []) -> int:
	GameState.bloquear()
	panel.show()
	nombre.text = quien
	UI.limpiar(opciones)
	for i in lineas.size():
		texto.text = lineas[i]
		if i == lineas.size() - 1 and not lista_opciones.is_empty():
			break
		aviso.show()
		_modo = 1
		await _avanzar
	var elegida := -1
	if not lista_opciones.is_empty():
		aviso.hide()
		for i in lista_opciones.size():
			var b := UI.boton(lista_opciones[i])
			b.pressed.connect(func(): _elegida.emit(i))
			opciones.add_child(b)
		_modo = 2
		(opciones.get_child(0) as Button).grab_focus()
		elegida = await _elegida
	_modo = 0
	UI.limpiar(opciones)
	panel.hide()
	await get_tree().process_frame  # la misma tecla no reabre la interacción
	GameState.desbloquear()
	return elegida


func _input(event: InputEvent) -> void:
	if _modo == 1 and (event.is_action_pressed("accion") or event.is_action_pressed("ui_accept")):
		get_viewport().set_input_as_handled()
		_modo = 0
		_avanzar.emit()
	elif _modo == 2 and event.is_action_pressed("accion"):
		UI.pulsar_foco(get_viewport(), opciones)


func _on_panel_gui_input(event: InputEvent) -> void:
	if _modo == 1 and event is InputEventMouseButton and event.pressed:
		_modo = 0
		_avanzar.emit()
