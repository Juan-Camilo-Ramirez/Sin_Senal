extends Interior
## Tienda de Camilo (entrada desde D3): solo el mostrador de Camilo y la
## ambientación. Sobre el mostrador están los conectores, los cables, la fuente
## y el router (sección 6.2).

const ARTE := preload("res://Assets/Maps/tienda.png")
const FILAS := [
		"####################",
		"####################",
		"###########C########",
		"####################",
		"##.##...############",
		"##.####.############",
		"##.####.yyyyyyyyyy##",
		"##...##.....########",
		"##..........########",
		"####........########",
		"####...............#",
		"#########XX#########",
]


func _textura() -> Texture2D:
	return ARTE


func _filas() -> PackedStringArray:
	return PackedStringArray(FILAS)
