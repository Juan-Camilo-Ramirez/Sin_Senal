class_name UI
extends RefCounted
## Acceso a las ventanas de la interfaz que viven en scene_game.tscn.
## Cada ventana se registra en un grupo al iniciar.


static func _buscar(grupo: StringName) -> Node:
	var arbol := Engine.get_main_loop() as SceneTree
	return arbol.get_first_node_in_group(grupo)


static func dialogo() -> Node:
	return _buscar(&"ui_dialogo")


static func capsula() -> Node:
	return _buscar(&"ui_capsula")


static func mostrador() -> Node:
	return _buscar(&"ui_mostrador")


static func sintomas() -> Node:
	return _buscar(&"ui_sintomas")


static func mesa() -> Node:
	return _buscar(&"ui_mesa")


## Pulsa el botón que tiene el foco (para usar la tecla de acción en menús).
static func pulsar_foco(viewport: Viewport, contenedor: Control) -> bool:
	var foco := viewport.gui_get_focus_owner()
	if foco is Button and contenedor.is_ancestor_of(foco) and not (foco as Button).disabled:
		viewport.set_input_as_handled()
		(foco as Button).pressed.emit()
		return true
	return false


## Botón con el texto ajustado al ancho (Godot 4.3+).
static func boton(texto: String) -> Button:
	var b := Button.new()
	b.text = texto
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if "autowrap_mode" in b:
		b.set("autowrap_mode", TextServer.AUTOWRAP_WORD_SMART)
	return b


## Pone el ícono de una pieza en un botón, ajustado al alto del texto.
static func con_icono(b: Button, pieza: PiezaData) -> Button:
	if pieza and pieza.icono:
		b.icon = pieza.icono
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 14)
		b.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return b


static func limpiar(contenedor: Node) -> void:
	for hijo in contenedor.get_children():
		contenedor.remove_child(hijo)
		hijo.queue_free()
