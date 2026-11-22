extends MapaBase
## Pueblo (overworld) de Alto Verde: 20 pantallas (5 columnas × 4 filas) de
## 256 × 176 px con tiles de 16 × 16 (16 × 11 tiles por pantalla), sección 6.1.
## El arte es Assets/Maps/pueblo.png (1280 × 704) y se dibuja con un
## TileMapLayer; las colisiones salen de PANTALLAS.
## Cámara: sigue al jugador de forma continua (con suavizado), sin salirse del
## mapa. Con CAMARA_POR_PANTALLAS = true vuelve al salto por pantallas de Zelda
## 1986 (256 px en horizontal o 176 px en vertical).

const ARTE := preload("res://Assets/Maps/pueblo.png")
const ANCHO_PANTALLA := 256
const ALTO_PANTALLA := 176
const TILES_X := 16
const TILES_Y := 11
const COLUMNAS := ["A", "B", "C", "D", "E"]
const FILAS := 4
## false = cámara que sigue al jugador; true = salto por pantallas.
const CAMARA_POR_PANTALLAS := false
## Margen para no saltar de pantalla una y otra vez cuando el camino del
## arte pasa justo por el borde entre dos pantallas.
const MARGEN_SALTO := 6.0

## Texto del aviso de interacción de cada puerta.
const TEXTO_PUERTAS := {
	"E": "Entrar a la sala de sistemas", "J": "Entrar a la casa de la junta",
	"P": "Entrar al depósito del colegio", "O": "Entrar a la oficina del rector",
	"R": "Entrar al taller de electricidad", "N": "Entrar a la tienda de Camilo",
}

## Cartel con el nombre de cada edificio con puerta: [texto, desplazamiento
## vertical en píxeles desde el centro de la puerta]. Queda sobre el techo.
const CARTELES := {
	"P": ["Depósito del colegio", -34],
	"O": ["Oficina del rector", -30],
	"E": ["Sala de sistemas", -56],
	"J": ["Casa de la junta", -32],
	"R": ["Taller de electricidad", -30],
	"N": ["Tienda de Camilo", -32],
}

## Puertas con interior (marca [E] en la sección 6.1).
## La escuela está repartida en 3 construcciones seguidas sobre el camino norte:
## depósito (B1), oficina del rector (C1) y sala de sistemas (D1, bandera azul).
const PUERTAS := {
	"E": "res://Scenes/World/Interiores/Escuela.tscn",        # D1: sala de sistemas
	"P": "res://Scenes/World/Interiores/Deposito.tscn",       # B1: depósito del colegio
	"O": "res://Scenes/World/Interiores/OficinaRector.tscn",  # C1: oficina del rector
	"J": "res://Scenes/World/Interiores/CasaJunta.tscn",      # C2
	"R": "res://Scenes/World/Interiores/Taller.tscn",     # B3 en el arte (A3 en el documento)
	"N": "res://Scenes/World/Interiores/Tienda.tscn",     # D3
}

## Colisiones del arte, pantalla por pantalla (16 × 11 tiles).
## .  caminable   #  bloquea   @ inicio   S Sofía   Q Don Pedro
## Puertas: E sala de sistemas, P depósito, O oficina del rector, J junta, R taller, N tienda
const PANTALLAS := {
	"A1": [
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"###............#",
	],
	"B1": [
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"#############P##",
		"############..##",
		"############..##",
		"############..##",
	],
	"C1": [
		"################",
		"################",
		"################",
		"################",
		"################",
		"########O#######",
		"####.##...##.###",
		"####.##...##.###",
		"####.........###",
		"####.........###",
		"#######..#######",
	],
	"D1": [
		"################",
		"##############..",
		"##############.#",
		"##############.#",
		"##############.#",
		"##############.#",
		"##############.#",
		"##############..",
		"##############..",
		"######EE######..",
		"#####....#####..",
	],
	"E1": [
		"################",
		"..##############",
		"..##############",
		".....###########",
		"...#############",
		"...#############",
		"...#############",
		".#.#############",
		".#.#############",
		".#.#############",
		".#...###########",
	],
	"A2": [
		"###########.....",
		"###############.",
		"################",
		"################",
		"################",
		"################",
		"################",
		"########...#####",
		"########...#####",
		"########...#####",
		"................",
	],
	"B2": [
		"................",
		"................",
		"############..##",
		"############..##",
		"############..##",
		"############..##",
		"############..##",
		"############..##",
		"############..##",
		"############..##",
		"................",
	],
	"C2": [
		"................",
		"................",
		"#######..#######",
		"#######..#######",
		"#######..#######",
		"#######..#######",
		"#######..#######",
		"#######..#######",
		"#######..#######",
		"###J###..#######",
		"................",
	],
	"D2": [
		"................",
		"................",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"................",
	],
	"E2": [
		"################",
		".....###########",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"................",
	],
	"A3": [
		"................",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
	],
	"B3": [
		".....#######..##",
		"############..##",
		"############..##",
		"#######RR###..##",
		"#####.........##",
		"#####..####...##",
		"#####..####...##",
		"####..........##",
		"####............",
		"####..##########",
		"####..##########",
	],
	"C3": [
		"##..##....##....",
		"##..##...###....",
		"##....####......",
		"##..#S####.#.Q..",
		"##....####......",
		"##..##....##....",
		"##..##...###....",
		"##..............",
		"................",
		"########.#######",
		"########.#######",
	],
	"D3": [
		"..##############",
		"..##############",
		"..##############",
		"..##############",
		"..##N###########",
		"........########",
		"........########",
		"..##############",
		"..##############",
		"################",
		"################",
	],
	"E3": [
		"###.............",
		"##########.#####",
		"##########.#####",
		"##########.#####",
		"##########.#####",
		"##########.#####",
		"##########.#####",
		"##########.#####",
		"######.....#####",
		"######.#########",
		"######.#########",
	],
	"A4": [
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"......@.........",
		"################",
		"################",
		"################",
	],
	"B4": [
		"####..##########",
		"####..##########",
		"####..##########",
		"####..##########",
		"####..##########",
		"####..##########",
		"####..##########",
		"................",
		"################",
		"################",
		"################",
	],
	"C4": [
		"########.#######",
		"########.#######",
		"########.#######",
		"########.#######",
		"########.#######",
		"########.#######",
		"########.#######",
		"................",
		"################",
		"################",
		"################",
	],
	"D4": [
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"################",
		"................",
		"################",
		"################",
		"################",
	],
	"E4": [
		"######.#########",
		"######.#########",
		"######.#########",
		"######.#########",
		"######.#########",
		"######.#########",
		"######..........",
		".#####..........",
		"################",
		"################",
		"################",
	],
}

var _pantalla := Vector2i(-99, -99)
var _puertas: Dictionary = {}  # char -> [celdas]


func _ready() -> void:
	var filas := PackedStringArray()
	for fila in FILAS:
		for y in TILES_Y:
			var linea := ""
			for col in COLUMNAS:
				linea += PANTALLAS[col + str(fila + 1)][y]
			filas.append(linea)
	var marcadores := ConstructorMapa.construir_arte(capa, ARTE, filas, Vector2i.ZERO)
	for m in marcadores:
		_crear_marcador(m)
	# Las puertas pueden ocupar 2 tiles: una sola puerta por edificio.
	for ch in _puertas:
		var celdas: Array = _puertas[ch]
		var pos := ConstructorMapa.centro_de(celdas)
		# Al salir del interior, el jugador reaparece frente a la puerta (abajo).
		var regreso := pos + Vector2(0, ConstructorMapa.TILE)
		_crear_puerta(pos, PUERTAS[ch], Vector2.INF, regreso, TEXTO_PUERTAS[ch])
		if CARTELES.has(ch):
			ConstructorMapa.cartel(entidades, CARTELES[ch][0], pos + Vector2(0, CARTELES[ch][1]))
	ConstructorMapa.etiqueta(entidades, "Bienvenidos a Alto Verde", _inicio + Vector2(-40, -30), 7)
	_colocar_jugador()
	camara.make_current()
	_actualizar_camara(true)
	camara.reset_smoothing()


func _crear_marcador(m: Dictionary) -> void:
	var ch: String = m.char
	if PUERTAS.has(ch):
		if not _puertas.has(ch):
			_puertas[ch] = []
		_puertas[ch].append(m.celda)
	else:
		super(m)


func _physics_process(_delta: float) -> void:
	_actualizar_camara()


## La franja superior de 64 px la cubre el HUD.
func _actualizar_camara(forzar := false) -> void:
	var pos := jugador.position
	if not CAMARA_POR_PANTALLAS:
		var mapa := Rect2(Vector2.ZERO, Vector2(ANCHO_PANTALLA * COLUMNAS.size(), ALTO_PANTALLA * FILAS))
		camara.position = (_encuadre(mapa, pos) - Vector2(0, HUD_ALTO)).round()
		return
	var p := Vector2i(floori(pos.x / ANCHO_PANTALLA), floori(pos.y / ALTO_PANTALLA))
	if p == _pantalla:
		return
	if not forzar:
		# Solo salta cuando el jugador ya cruzó el borde unos píxeles.
		if p.x != _pantalla.x and absf(pos.x - maxi(p.x, _pantalla.x) * ANCHO_PANTALLA) < MARGEN_SALTO:
			return
		if p.y != _pantalla.y and absf(pos.y - maxi(p.y, _pantalla.y) * ALTO_PANTALLA) < MARGEN_SALTO:
			return
	_pantalla = p
	camara.position = Vector2(p.x * ANCHO_PANTALLA, p.y * ALTO_PANTALLA - HUD_ALTO)
