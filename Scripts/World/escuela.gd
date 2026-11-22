extends Interior
## Escuela La Esperanza: sala de sistemas (la casa de la bandera azul, D1).
## Marta, los equipos dañados y la mesa de instalación (sección 6.2).

const ARTE := preload("res://Assets/Maps/aula.png")
const FILAS := [
		"################################",
		"################################",
		"################################",
		"################################",
		"################################",
		"#.####.###....####....#####..###",
		"#.kkkk.kkk....####.M..kk.....###",
		"#...........iiiiiiiii........###",
		"#####.####..#########........###",
		"#####.####..iiiiiiiii........###",
		"#####.####.............#########",
		"#......................#########",
		"#......................#########",
		"###############XX###############",
		"################################",
]


func _ready() -> void:
	GameState.set_bandera(&"visito_escuela")
	super()


func _textura() -> Texture2D:
	return ARTE


func _filas() -> PackedStringArray:
	return PackedStringArray(FILAS)
