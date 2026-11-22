extends CanvasLayer
## Mostrador (mecánica 4): lista de objetos de la tienda o de la estantería
## del depósito. El jugador elige cuáles llevarse según los síntomas que
## conoce. Entre ellos hay trampas y el mostrador no da pistas.
## Cada objeto se puede tomar una sola vez.

signal _cerrado

@onready var fondo: ColorRect = $Fondo
@onready var titulo: Label = $Fondo/Panel/Titulo
@onready var lista: VBoxContainer = $Fondo/Panel/Lista
@onready var mensaje: Label = $Fondo/Panel/Mensaje
@onready var cerrar: Button = $Fondo/Panel/Cerrar

var _items: Array = []
var _abierto := false


func _ready() -> void:
	add_to_group(&"ui_mostrador")
	fondo.hide()
	cerrar.pressed.connect(_cerrar)


## items: [{"id": StringName, "texto": String, "probar": bool (opcional)}]
func abrir(nombre: String, items: Array) -> void:
	if _abierto:
		return
	_abierto = true
	GameState.bloquear()
	_items = items
	titulo.text = nombre
	mensaje.text = "Elige qué llevar. Espacio libre: %d/%d" % [GameState.espacios_libres(), GameState.MAX_INVENTARIO]
	_refrescar()
	fondo.show()
	await _cerrado
	fondo.hide()
	await get_tree().process_frame
	_abierto = false
	GameState.desbloquear()


func _cerrar() -> void:
	if _abierto:
		_cerrado.emit()


func _refrescar() -> void:
	UI.limpiar(lista)
	for item in _items:
		if GameState.fue_tomado(item.id):
			continue
		var texto: String = item.texto
		if item.get("probar", false) and GameState.get_bandera(_bandera_prueba(item.id)):
			texto += " (probado)"
		var b := UI.con_icono(UI.boton(texto), GameState.obtener_pieza(item.id))
		b.pressed.connect(_elegir.bind(item))
		lista.add_child(b)
	if lista.get_child_count() == 0:
		var vacio := Label.new()
		vacio.text = "(No queda nada.)"
		lista.add_child(vacio)
		cerrar.grab_focus()
	else:
		(lista.get_child(0) as Control).grab_focus()


func _bandera_prueba(id: StringName) -> StringName:
	return StringName("probado_%s" % id)


func _elegir(item: Dictionary) -> void:
	# El switch golpeado hay que probarlo en un tomacorriente antes de cargarlo.
	if item.get("probar", false) and not GameState.get_bandera(_bandera_prueba(item.id)):
		_mostrar_prueba(item)
		return
	if not GameState.agregar_al_inventario(item.id):
		mensaje.text = Dialogos.INVENTARIO_LLENO
		return
	GameState.marcar_tomado(item.id)
	mensaje.text = "Guardaste: %s. Espacio libre: %d/%d" % [item.texto, GameState.espacios_libres(), GameState.MAX_INVENTARIO]
	_refrescar()


func _mostrar_prueba(item: Dictionary) -> void:
	mensaje.text = Dialogos.SWITCH_SIN_PROBAR
	UI.limpiar(lista)
	var probar := UI.boton("Probar en el tomacorriente")
	probar.pressed.connect(_probar.bind(item))
	lista.add_child(probar)
	var volver := UI.boton("Volver")
	volver.pressed.connect(_refrescar)
	lista.add_child(volver)
	probar.grab_focus()


func _probar(item: Dictionary) -> void:
	GameState.set_bandera(_bandera_prueba(item.id))
	mensaje.text = Dialogos.SWITCH_PROBADO
	_refrescar()


func _input(event: InputEvent) -> void:
	if not _abierto:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar()
	elif event.is_action_pressed("accion"):
		UI.pulsar_foco(get_viewport(), fondo)
