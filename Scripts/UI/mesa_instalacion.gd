extends CanvasLayer
## Mesa de instalación del aula de sistemas (mecánicas 8, 9 y 10).
## Tiene un lugar para cada pieza. El jugador elige una pieza del inventario y
## el lugar donde la coloca, en este orden:
##   a. regulador  b. switch  c. ponchar (cable + RJ45 + crimpadora)
##   d. probar (probador)  e. punto de acceso  f. prueba final
## - Pieza trampa en cualquier lugar: Marta explica su función, da la pista y
##   la pieza se retira del inventario (8.2). No cuenta como error.
## - Pieza correcta en lugar equivocado: Marta explica dónde va.
## - Paso fuera de orden: no se permite y Marta explica por qué va antes el otro.
## No hay contador de errores ni castigo.

signal _cerrado

## Un lugar para cada pieza: [id de la pieza que va ahí, texto del lugar].
const LUGARES := [
	[&"regulador", "Regulador -> router"],
	[&"switch", "Switch"],
	[&"cable_utp", "Cable"],
	[&"conectores_rj45", "Conectores"],
	[&"kit_ponchado", "Crimpadora / probador"],
	[&"punto_acceso", "Punto de acceso"],
]
const PIEZAS_PONCHAR := [&"cable_utp", &"conectores_rj45", &"kit_ponchado"]
const LETRAS := ["a", "b", "c", "d", "e", "f"]

@onready var fondo: ColorRect = $Fondo
@onready var paso: Label = $Fondo/Panel/Paso
@onready var lista_inventario: VBoxContainer = $Fondo/Panel/Inventario
@onready var lista_lugares: VBoxContainer = $Fondo/Panel/Lugares
@onready var marta: Label = $Fondo/Panel/Marta/Texto
@onready var boton_probar: Button = $Fondo/Panel/Acciones/Probar
@onready var boton_final: Button = $Fondo/Panel/Acciones/PruebaFinal
@onready var boton_cerrar: Button = $Fondo/Panel/Acciones/Cerrar

var _seleccion: PiezaData = null
var _abierta := false


func _ready() -> void:
	add_to_group(&"ui_mesa")
	fondo.hide()
	boton_probar.pressed.connect(_on_probar)
	boton_final.pressed.connect(_on_prueba_final)
	boton_cerrar.pressed.connect(_cerrar)


func abrir() -> void:
	if _abierta:
		return
	_abierta = true
	GameState.bloquear()
	_seleccion = null
	_decir(Dialogos.MESA_ELEGIR_PIEZA)
	_refrescar()
	fondo.show()
	await _cerrado
	fondo.hide()
	await get_tree().process_frame
	_abierta = false
	GameState.desbloquear()


func _cerrar() -> void:
	if _abierta:
		_cerrado.emit()


func _decir(texto: String) -> void:
	marta.text = texto


func _refrescar() -> void:
	if GameState.instalacion_completa():
		paso.text = "Instalación completa."
	else:
		var i := GameState.paso_actual
		paso.text = "Paso actual: %s. %s" % [LETRAS[i], GameState.NOMBRES_PASOS[GameState.ORDEN_INSTALACION[i]]]
	# Inventario
	UI.limpiar(lista_inventario)
	for pieza in GameState.inventario:
		var marca := "> " if pieza == _seleccion else ""
		var b := Button.new()
		b.text = marca + pieza.nombre
		b.clip_text = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		UI.con_icono(b, pieza)
		b.pressed.connect(_on_pieza.bind(pieza))
		lista_inventario.add_child(b)
	if GameState.inventario.is_empty():
		var vacio := Label.new()
		vacio.text = "(vacío)"
		lista_inventario.add_child(vacio)
	# Lugares
	UI.limpiar(lista_lugares)
	for lugar in LUGARES:
		var instalada := GameState.esta_instalada(lugar[0])
		var b := Button.new()
		b.text = lugar[1] + (" [OK]" if instalada else "")
		b.clip_text = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = instalada
		UI.con_icono(b, GameState.obtener_pieza(lugar[0]))
		b.pressed.connect(_on_lugar.bind(lugar[0]))
		lista_lugares.add_child(b)
	_enfocar()


func _enfocar() -> void:
	var destino: Control = boton_cerrar
	if _seleccion != null:
		for b in lista_lugares.get_children():
			if b is Button and not b.disabled:
				destino = b as Control
				break
	elif lista_inventario.get_child_count() > 0 and lista_inventario.get_child(0) is Button:
		destino = lista_inventario.get_child(0) as Control
	destino.grab_focus()


func _on_pieza(pieza: PiezaData) -> void:
	_seleccion = pieza
	_decir("Elegiste: %s. Ahora elige el lugar de la mesa." % pieza.nombre)
	_refrescar()


func _on_lugar(lugar: StringName) -> void:
	if _seleccion == null:
		_decir(Dialogos.MESA_ELEGIR_PIEZA)
		return
	var pieza := _seleccion
	_seleccion = null
	if pieza.es_trampa():
		# Pista solo en el aula; la pieza se retira del inventario.
		GameState.quitar_del_inventario(pieza.id)
		_decir(Dialogos.MESA_TRAMPA % [pieza.nombre, pieza.funcion, pieza.pista])
	elif pieza.id != lugar:
		_decir(pieza.pista)  # Marta explica dónde va.
	elif GameState.indice_de_paso(pieza.paso) > GameState.paso_actual:
		_decir(Dialogos.FUERA_DE_ORDEN[GameState.paso_id_actual()])
	else:
		_instalar(pieza)
		return
	_refrescar()


func _instalar(pieza: PiezaData) -> void:
	GameState.quitar_del_inventario(pieza.id)
	GameState.marcar_instalada(pieza.id)
	var texto: String = Dialogos.MESA_INSTALADA % pieza.nombre
	if pieza.paso == &"ponchar":
		var faltan := _faltan_para_ponchar()
		if faltan.is_empty():
			GameState.avanzar_paso()
		else:
			texto += " " + Dialogos.MESA_PONCHAR_FALTA % ", ".join(faltan)
	else:
		GameState.avanzar_paso()
	_decir(texto)
	_refrescar()
	await UI.capsula().mostrar(pieza.capsula)
	_enfocar()


func _faltan_para_ponchar() -> PackedStringArray:
	var faltan: PackedStringArray = []
	for id in PIEZAS_PONCHAR:
		if not GameState.esta_instalada(id):
			faltan.append(GameState.obtener_pieza(id).nombre)
	return faltan


func _on_probar() -> void:
	var actual := GameState.paso_id_actual()
	if actual == &"probar":
		GameState.avanzar_paso()
		_decir(Dialogos.MESA_PROBADO)
	elif GameState.paso_actual < GameState.indice_de_paso(&"probar"):
		_decir(Dialogos.FUERA_DE_ORDEN[actual])
	else:
		_decir(Dialogos.MESA_YA_PROBADO)
	_refrescar()


func _on_prueba_final() -> void:
	var actual := GameState.paso_id_actual()
	if actual == &"prueba_final":
		GameState.avanzar_paso()
		_decir(Dialogos.MESA_FINAL)
		_refrescar()
		await get_tree().create_timer(2.5).timeout
		_cerrar()
		GameState.terminar_juego()
	elif not GameState.instalacion_completa():
		_decir(Dialogos.FUERA_DE_ORDEN[actual])


func _input(event: InputEvent) -> void:
	if not _abierta:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cerrar()
	elif event.is_action_pressed("accion"):
		UI.pulsar_foco(get_viewport(), fondo)
