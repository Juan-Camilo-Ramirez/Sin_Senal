extends CanvasLayer
## Test inicial (reemplaza al video de introducción).
## 1. Muestra la llamada de Don Hernán.
## 2. Hace 8 preguntas sobre los ítems del juego (Dialogos.TEST_PREGUNTAS),
##    con las opciones mezcladas y un contador de respuestas buenas y malas.
##    Después de cada respuesta marca la correcta y muestra la explicación.
## 3. Muestra el resultado y emite «terminado». No hay castigo: con cualquier
##    puntaje se empieza a jugar.

signal terminado(buenas: int, malas: int)

const COLOR_BIEN := Color(0.15, 0.45, 0.2, 1)
const COLOR_MAL := Color(0.55, 0.15, 0.15, 1)
const COLOR_TEXTO_BIEN := Color(0.45, 0.95, 0.45, 1)
const COLOR_TEXTO_MAL := Color(1, 0.45, 0.4, 1)

enum Fase { LLAMADA, PREGUNTA, RESPONDIDA, RESULTADO }

@onready var progreso: Label = $Progreso
@onready var lbl_buenas: Label = $Buenas
@onready var lbl_malas: Label = $Malas
@onready var pregunta: Label = $Contenido/Pregunta
@onready var opciones: VBoxContainer = $Contenido/Opciones
@onready var retro: Label = $Contenido/Retro
@onready var siguiente: Button = $Siguiente

var _fase := Fase.LLAMADA
var _indice := 0
var _buenas := 0
var _malas := 0
## Botones de la pregunta actual y cuál es el correcto.
var _botones: Array[Button] = []
var _boton_correcto: Button


func _ready() -> void:
	randomize()
	siguiente.pressed.connect(_on_siguiente)
	_actualizar_marcador()
	progreso.text = "Test inicial"
	pregunta.text = Dialogos.LLAMADA_DON_HERNAN
	retro.text = Dialogos.TEST_INTRO
	retro.remove_theme_color_override("font_color")
	siguiente.text = "Comenzar"
	siguiente.show()
	siguiente.grab_focus()


func _on_siguiente() -> void:
	match _fase:
		Fase.LLAMADA:
			_indice = 0
			_mostrar_pregunta()
		Fase.RESPONDIDA:
			_indice += 1
			if _indice < Dialogos.TEST_PREGUNTAS.size():
				_mostrar_pregunta()
			else:
				_mostrar_resultado()
		Fase.RESULTADO:
			_fase = Fase.LLAMADA  # evita emitir dos veces
			siguiente.disabled = true
			terminado.emit(_buenas, _malas)


func _mostrar_pregunta() -> void:
	_fase = Fase.PREGUNTA
	var datos: Dictionary = Dialogos.TEST_PREGUNTAS[_indice]
	progreso.text = "Pregunta %d/%d" % [_indice + 1, Dialogos.TEST_PREGUNTAS.size()]
	pregunta.text = datos["pregunta"]
	retro.text = ""
	siguiente.hide()
	UI.limpiar(opciones)
	_botones.clear()
	_boton_correcto = null

	# Mezcla el orden de las opciones en cada partida.
	var orden := range(datos["opciones"].size())
	orden.shuffle()
	var letras := ["a", "b", "c", "d"]
	for i in orden.size():
		var original: int = orden[i]
		var b := UI.boton("%s) %s" % [letras[i], datos["opciones"][original]])
		b.add_theme_font_size_override("font_size", 7)
		b.custom_minimum_size = Vector2(240, 0)
		opciones.add_child(b)
		_botones.append(b)
		if original == int(datos["correcta"]):
			_boton_correcto = b
		b.pressed.connect(_on_respuesta.bind(b))
	_botones[0].grab_focus()


func _on_respuesta(elegido: Button) -> void:
	if _fase != Fase.PREGUNTA:
		return
	_fase = Fase.RESPONDIDA
	var acierto := elegido == _boton_correcto
	if acierto:
		_buenas += 1
	else:
		_malas += 1
	_actualizar_marcador()

	# Marca la correcta en verde y, si falló, la elegida en rojo.
	for b in _botones:
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if b == _boton_correcto:
			_pintar(b, COLOR_BIEN)
		elif b == elegido:
			_pintar(b, COLOR_MAL)
		else:
			b.modulate = Color(1, 1, 1, 0.45)

	var datos: Dictionary = Dialogos.TEST_PREGUNTAS[_indice]
	retro.add_theme_color_override("font_color", COLOR_TEXTO_BIEN if acierto else COLOR_TEXTO_MAL)
	retro.text = ("¡Correcto! " if acierto else "Incorrecto. ") + str(datos["explicacion"])
	var ultima := _indice >= Dialogos.TEST_PREGUNTAS.size() - 1
	siguiente.text = "Ver resultado" if ultima else "Siguiente"
	siguiente.show()
	siguiente.grab_focus()


func _mostrar_resultado() -> void:
	_fase = Fase.RESULTADO
	UI.limpiar(opciones)
	_botones.clear()
	var total := Dialogos.TEST_PREGUNTAS.size()
	progreso.text = "Resultado"
	pregunta.text = "Terminaste el test.\n\nRespuestas buenas: %d de %d\nRespuestas malas: %d de %d" % [_buenas, total, _malas, total]
	retro.remove_theme_color_override("font_color")
	if _buenas == total:
		retro.text = "¡Excelente! Conoces todos los equipos. Ahora ve a la escuela y repara la conexión."
	elif _buenas * 2 >= total:
		retro.text = "¡Bien! Durante el juego las cápsulas y los personajes te ayudarán con lo que falta."
	else:
		retro.text = "No te preocupes: durante el juego vas a aprender para qué sirve cada equipo. Revisa bien las piezas antes de instalarlas."
	siguiente.text = "Empezar a jugar"
	siguiente.show()
	siguiente.grab_focus()


func _actualizar_marcador() -> void:
	lbl_buenas.text = "Buenas: %d" % _buenas
	lbl_malas.text = "Malas: %d" % _malas


func _pintar(b: Button, color: Color) -> void:
	var caja := StyleBoxFlat.new()
	caja.bg_color = color
	caja.border_color = color.lightened(0.4)
	caja.set_border_width_all(1)
	caja.set_content_margin_all(2)
	caja.content_margin_left = 4
	caja.content_margin_right = 4
	for estilo in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(estilo, caja)


## E o Espacio pulsan el botón que tiene el foco (las flechas lo mueven).
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accion"):
		var foco := get_viewport().gui_get_focus_owner()
		if foco is Button and foco.is_visible_in_tree() and not (foco as Button).disabled:
			get_viewport().set_input_as_handled()
			(foco as Button).pressed.emit()
