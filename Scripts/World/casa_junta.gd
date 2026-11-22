extends Interior
## Casa de la junta (entrada desde C1): sala pequeña con mesa y estante de
## herramientas, y Doña Luz (sección 6.2).

const ARTE := preload("res://Assets/Maps/casa_junta.png")
const FILAS := [
		"####################",
		"####################",
		"####################",
		"####################",
		"####################",
		"###..#########.#####",
		"###..#########L#####",
		"###..#########.#####",
		"###..............###",
		"####............####",
		"####............####",
		"#########XX#########",
]


func _textura() -> Texture2D:
	return ARTE


func _filas() -> PackedStringArray:
	return PackedStringArray(FILAS)
