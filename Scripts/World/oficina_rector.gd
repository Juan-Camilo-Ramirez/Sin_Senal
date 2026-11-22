extends Interior
## Oficina del rector (edificio de techo gris con patio, C1): Don Hernán y el
## punto de acceso de un proyecto anterior (sección 6.2).

const ARTE := preload("res://Assets/Maps/oficina.png")
const FILAS := [
		"####################",
		"####################",
		"####################",
		"####################",
		"########.#####...###",
		"######..H#####.....#",
		"######...#...#..####",
		"######...#...#..####",
		"######..........####",
		"#...............####",
		"#..................#",
		"#########XX#########",
]


func _textura() -> Texture2D:
	return ARTE


func _filas() -> PackedStringArray:
	return PackedStringArray(FILAS)
