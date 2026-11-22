extends Control
## Inventario con 6 casillas visibles (sección 14): ícono de cada pieza y su
## nombre corto.

const ANCHO_CASILLA := 26

@onready var titulo: Label = $Titulo
@onready var casillas: HBoxContainer = $Casillas


func _ready() -> void:
	for i in GameState.MAX_INVENTARIO:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(ANCHO_CASILLA, 34)
		var icono := TextureRect.new()
		icono.name = "Icono"
		icono.position = Vector2(3, 1)
		icono.size = Vector2(20, 17)
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icono.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		panel.add_child(icono)
		var etiqueta := Label.new()
		etiqueta.name = "Etiqueta"
		etiqueta.position = Vector2(0, 18)
		etiqueta.size = Vector2(ANCHO_CASILLA, 14)
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta.add_theme_font_size_override("font_size", 6)
		panel.add_child(etiqueta)
		casillas.add_child(panel)
	GameState.inventario_cambiado.connect(_actualizar)
	_actualizar()


func _actualizar() -> void:
	titulo.text = "Inventario %d/%d" % [GameState.inventario.size(), GameState.MAX_INVENTARIO]
	for i in casillas.get_child_count():
		var panel := casillas.get_child(i)
		var icono: TextureRect = panel.get_node("Icono")
		var etiqueta: Label = panel.get_node("Etiqueta")
		if i < GameState.inventario.size():
			var pieza: PiezaData = GameState.inventario[i]
			icono.texture = pieza.icono
			icono.visible = true
			etiqueta.text = pieza.nombre_corto
			panel.tooltip_text = pieza.nombre
		else:
			icono.visible = false
			etiqueta.text = ""
			panel.tooltip_text = ""
