class_name ConstructorMapa
extends RefCounted
## Construye un TileMapLayer a partir de una imagen de arte (pueblo o sala) y
## de una cuadrícula de texto con la misma medida en tiles de 16 × 16 px
## (sección 15.1). Cada tile de 16 × 16 de la imagen es un tile del atlas, así
## que la capa dibuja el arte y, a la vez, lleva las colisiones.
##
## Leyenda de la cuadrícula:
##   .  se puede caminar            #  bloquea el paso (regla 6.3)
##   @  inicio del jugador (A4)
##   E P O J R N  puertas del pueblo: Escuela (sala de sistemas), dePósito,
##                Oficina del rector, Junta, taller (R), tieNda
##   X  salida de un interior al pueblo
##   S Q M H L C G  personajes (Sofía, Don Pedro, Marta, Don Hernán,
##                  Doña Luz, Camilo, Don Jorge)
##   k equipos dañados  i mesa de instalación  e estantería del depósito
##   y mostrador de la tienda  z mostrador del taller

const TILE := 16

## Caracteres que bloquean el paso (además de "#").
const SOLIDOS := "#EJRNPOXkieyz"
## Caracteres que crean un nodo (puerta, personaje, objeto o inicio).
const MARCADORES := "@EJRNPOXSQMHLCGkieyz"


## Pinta `textura` en `capa` a partir de la celda `origen` y le pone colisión
## a cada tile sólido según `filas`. Devuelve los marcadores encontrados:
## [{"char": String, "celda": Vector2i}].
static func construir_arte(capa: TileMapLayer, textura: Texture2D, filas: PackedStringArray, origen: Vector2i) -> Array:
	var columnas := textura.get_width() / TILE
	var renglones := textura.get_height() / TILE
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	var fuente := TileSetAtlasSource.new()
	fuente.texture = textura
	fuente.texture_region_size = Vector2i(TILE, TILE)
	ts.add_source(fuente, 0)
	capa.tile_set = ts
	var medio := TILE / 2.0
	var cuadrado := PackedVector2Array([
		Vector2(-medio, -medio), Vector2(medio, -medio),
		Vector2(medio, medio), Vector2(-medio, medio)])
	var marcadores: Array = []
	for y in renglones:
		var fila: String = filas[y] if y < filas.size() else ""
		for x in columnas:
			var ch := fila[x] if x < fila.length() else "#"
			var coords := Vector2i(x, y)
			fuente.create_tile(coords)
			if SOLIDOS.contains(ch):
				var datos := fuente.get_tile_data(coords, 0)
				datos.add_collision_polygon(0)
				datos.set_collision_polygon_points(0, 0, cuadrado)
			capa.set_cell(origen + coords, 0, coords)
			if MARCADORES.contains(ch):
				marcadores.append({"char": ch, "celda": origen + coords})
	return marcadores


static func centro(celda: Vector2i) -> Vector2:
	return Vector2(celda * TILE) + Vector2(TILE, TILE) / 2.0


## Promedio de los centros de varias celdas (puertas de 2 o 3 tiles).
static func centro_de(celdas: Array) -> Vector2:
	var suma := Vector2.ZERO
	for c in celdas:
		suma += centro(c)
	return suma / maxi(celdas.size(), 1)


## Etiqueta de texto sobre el mapa.
static func etiqueta(padre: Node, texto: String, posicion: Vector2, tamano := 8, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = posicion
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 3)
	l.z_index = 5
	padre.add_child(l)
	return l


## Cartel de madera con el nombre de un edificio, centrado en «centro_cartel».
## Se usa en el pueblo para identificar cada construcción con puerta.
static func cartel(padre: Node, texto: String, centro_cartel: Vector2, tamano := 7) -> Panel:
	var fuente: Font = ThemeDB.fallback_font
	var ancho := ceilf(fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x) + 8.0
	var alto := float(tamano) + 5.0
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color(0.42, 0.26, 0.13, 1)
	caja.border_color = Color(0.22, 0.12, 0.05, 1)
	caja.set_border_width_all(1)
	caja.set_corner_radius_all(1)
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", caja)
	panel.size = Vector2(ancho, alto)
	panel.position = (centro_cartel - panel.size / 2.0).round()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 4
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", Color(1, 0.95, 0.8, 1))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(l)
	padre.add_child(panel)
	return panel
