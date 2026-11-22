extends CanvasLayer
## Lista de síntomas (mecánica 7): se desbloquea al revisar los equipos del
## aula por primera vez y se puede consultar en cualquier momento con Tab.
## Muestra el síntoma y la causa probable (sección 7).

signal cerrado

@onready var fondo: ColorRect = $Fondo
@onready var texto: Label = $Fondo/Panel/Texto

## scene_game la habilita durante la partida (no en la intro ni en el final).
var habilitado := false
var _abierta := false


func _ready() -> void:
	add_to_group(&"ui_sintomas")
	fondo.hide()


func abrir() -> void:
	if _abierta:
		return
	_abierta = true
	GameState.bloquear()
	if GameState.sintomas_desbloqueados:
		var lineas: PackedStringArray = []
		for s in GameState.SINTOMAS:
			lineas.append("- %s\n   Causa probable: %s" % [s.sintoma, s.causa])
		texto.text = "\n".join(lineas)
	else:
		texto.text = "Aún no tienes la lista. Revisa los equipos del aula de sistemas, en la escuela."
	fondo.show()


func cerrar() -> void:
	if not _abierta:
		return
	fondo.hide()
	_abierta = false
	GameState.desbloquear()
	cerrado.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ver_sintomas"):
		if _abierta:
			get_viewport().set_input_as_handled()
			cerrar()
		elif habilitado:
			get_viewport().set_input_as_handled()
			abrir()
	elif _abierta and (event.is_action_pressed("accion") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		cerrar()
