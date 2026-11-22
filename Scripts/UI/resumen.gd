extends CanvasLayer
## Final único (sección 13): escena de cierre, mensaje final y resumen con las
## piezas instaladas, las personas ayudadas (0/4) y los conceptos aprendidos.
## Abajo hay dos botones: «Jugar de nuevo» (partida nueva desde el pueblo) y
## «Salir del juego». En la web no se puede cerrar la pestaña, así que ese
## botón se llama «Volver al inicio» y lleva a la pantalla de inicio.
## Flechas arriba/abajo (o W/S) desplazan el resumen; izquierda/derecha
## cambian de botón; E, Espacio, Enter o clic eligen.

signal jugar_de_nuevo
signal salir

## Pausa antes de aceptar los botones, para que una tecla pulsada justo al
## terminar la prueba final no elija una opción sin querer.
const ESPERA_BOTONES := 0.8
const PASO_DESPLAZAMIENTO := 12.0

@onready var fondo: ColorRect = $Fondo
@onready var cierre: Label = $Fondo/Escena/Cierre
@onready var mensaje: Label = $Fondo/Mensaje
@onready var resumen: RichTextLabel = $Fondo/Resumen
@onready var botones: HBoxContainer = $Fondo/Botones
@onready var boton_jugar: Button = $Fondo/Botones/JugarDeNuevo
@onready var boton_salir: Button = $Fondo/Botones/Salir

var _visible := false
var _listo := false   # los botones ya responden
var _elegido := false # ya se eligió una opción (evita dobles pulsaciones)


func _ready() -> void:
	fondo.hide()
	boton_jugar.pressed.connect(_elegir.bind(true))
	boton_salir.pressed.connect(_elegir.bind(false))
	if OS.has_feature("web"):
		boton_salir.text = "Volver al inicio"


func mostrar() -> void:
	GameState.bloquear()
	cierre.text = Dialogos.CIERRE
	mensaje.text = Dialogos.MENSAJE_FINAL
	var nombres: PackedStringArray = []
	var conceptos: PackedStringArray = []
	for id in GameState.piezas_instaladas:
		var pieza := GameState.obtener_pieza(id)
		nombres.append(pieza.nombre)
		conceptos.append("- %s: %s" % [pieza.nombre, pieza.funcion])
	var t := "[b]Resumen[/b]\n"
	t += "Piezas instaladas: %d/%d\n%s\n" % [nombres.size(), GameState.TOTAL_PIEZAS, ", ".join(nombres)]
	t += "Personas ayudadas: %d/%d\n\n" % [GameState.ayudas.size(), GameState.TOTAL_AYUDAS]
	t += "[b]Conceptos aprendidos[/b]\n" + "\n".join(conceptos)
	resumen.text = t
	resumen.scroll_to_line(0)
	_visible = true
	_listo = false
	_elegido = false
	fondo.show()
	boton_jugar.grab_focus()
	await get_tree().create_timer(ESPERA_BOTONES).timeout
	_listo = true


## Lo llama scene_game cuando ya está detrás del fundido a negro.
func ocultar() -> void:
	if not _visible:
		return
	_visible = false
	_listo = false
	fondo.hide()
	GameState.desbloquear()


func _elegir(de_nuevo: bool) -> void:
	if not _visible or not _listo or _elegido:
		return
	_elegido = true
	if de_nuevo:
		jugar_de_nuevo.emit()
	else:
		salir.emit()


func _input(event: InputEvent) -> void:
	if not _visible:
		return
	if event.is_action_pressed("accion"):
		get_viewport().set_input_as_handled()
		if _listo:
			UI.pulsar_foco(get_viewport(), botones)
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("mover_arriba"):
		get_viewport().set_input_as_handled()
		_desplazar(-PASO_DESPLAZAMIENTO)
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("mover_abajo"):
		get_viewport().set_input_as_handled()
		_desplazar(PASO_DESPLAZAMIENTO)
	elif event.is_action_pressed("mover_izquierda") or event.is_action_pressed("mover_derecha"):
		# A/D también cambian de botón (las flechas ya lo hacen con ui_left/ui_right).
		if not (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
			get_viewport().set_input_as_handled()
			(boton_salir if event.is_action_pressed("mover_derecha") else boton_jugar).grab_focus()


func _desplazar(cantidad: float) -> void:
	var barra := resumen.get_v_scroll_bar()
	barra.value = clampf(barra.value + cantidad, barra.min_value, barra.max_value)
