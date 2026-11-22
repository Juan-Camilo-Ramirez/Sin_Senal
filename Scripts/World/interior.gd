class_name Interior
extends MapaBase
## Base de los 4 interiores (sección 6.2). Cada interior es una escena distinta
## con una imagen de Assets/Maps/ y su cuadrícula de colisiones (leyenda en
## constructor_mapa.gd).
## - Cada grupo de tiles X es una salida al pueblo; al salir, el jugador
##   reaparece frente a la puerta del pueblo por la que entró.
## - Al entrar, el jugador aparece en la celda "entrada" (frente a la puerta,
##   por dentro).
## - La cámara sigue al jugador de forma continua, sin salirse de la sección
##   en la que está.


## Imagen del interior.
func _textura() -> Texture2D:
	return null


## Colisiones: una fila de texto por cada fila de tiles de la imagen.
func _filas() -> PackedStringArray:
	return PackedStringArray()


## Celda donde aparece el jugador al entrar. (-1, -1) = frente a la primera
## salida X, por dentro.
func _entrada() -> Vector2i:
	return Vector2i(-1, -1)


## Secciones para la cámara, en tiles (Rect2i). Por defecto, toda la imagen.
func _secciones() -> Array[Rect2i]:
	var t := _textura()
	return [Rect2i(Vector2i.ZERO, Vector2i(t.get_size()) / ConstructorMapa.TILE)]


## Etiquetas: [columna, fila, texto] en celdas.
func _etiquetas() -> Array:
	return []


var _rects: Array[Rect2] = []


func _ready() -> void:
	var marcadores := ConstructorMapa.construir_arte(capa, _textura(), _filas(), Vector2i.ZERO)
	var salidas: Array[Vector2i] = []
	for m in marcadores:
		if m.char == "X":
			salidas.append(m.celda)
		else:
			_crear_marcador(m)
	var grupos := _agrupar(salidas)
	for grupo in grupos:
		_crear_puerta(ConstructorMapa.centro_de(grupo), RUTA_PUEBLO, GameState.posicion_regreso, Vector2.INF, "Salir al pueblo")
	if _entrada() != Vector2i(-1, -1):
		_inicio = ConstructorMapa.centro(_entrada())
	elif not grupos.is_empty():
		_inicio = ConstructorMapa.centro_de(grupos[0]) - Vector2(0, ConstructorMapa.TILE)
	for s in _secciones():
		_rects.append(Rect2(Vector2(s.position * ConstructorMapa.TILE), Vector2(s.size * ConstructorMapa.TILE)))
	for e in _etiquetas():
		ConstructorMapa.etiqueta(entidades, e[2], Vector2(e[0], e[1]) * ConstructorMapa.TILE, 7)
	_colocar_jugador()
	camara.make_current()
	_actualizar_camara()
	camara.reset_smoothing()


## Agrupa celdas X vecinas: cada grupo es una puerta.
func _agrupar(celdas: Array[Vector2i]) -> Array:
	var grupos: Array = []
	for c in celdas:
		var puesto := false
		for g in grupos:
			for o in g:
				if absi(o.x - c.x) + absi(o.y - c.y) == 1:
					g.append(c)
					puesto = true
					break
			if puesto:
				break
		if not puesto:
			grupos.append([c])
	return grupos


func _physics_process(_delta: float) -> void:
	_actualizar_camara()


func _actualizar_camara() -> void:
	var seccion := Rect2()
	for r in _rects:
		if r.has_point(jugador.position):
			seccion = r
			break
	if seccion.size == Vector2.ZERO:
		return
	camara.position = (_encuadre(seccion, jugador.position) - Vector2(0, HUD_ALTO)).round()
