extends Interior
## Taller de electricidad: solo el mostrador de Don Jorge y la ambientación.
## Sobre el mostrador están el regulador y el multitoma (sección 6.2).

const ARTE := preload("res://Assets/Maps/taller.png")
const FILAS := [
		"####################",
		"####################",
		"####################",
		"######.########G...#",
		"##.....########..###",
		"##.....zzzzzzzz..###",
		"##...............###",
		"##...............###",
		"#.................##",
		"######........######",
		"######........######",
		"#########XXX########",
]


func _textura() -> Texture2D:
	return ARTE


func _filas() -> PackedStringArray:
	return PackedStringArray(FILAS)
