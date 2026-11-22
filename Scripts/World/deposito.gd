extends Interior
## Depósito del colegio (casa grande de techo rojo, B1): estantería con el
## switch golpeado, el hub viejo y el cable UTP, y el tomacorriente para
## probar el switch (sección 6.2).

const ARTE := preload("res://Assets/Maps/deposito.png")
const FILAS := [
		"####################",
		"####################",
		"####################",
		"########.###########",
		"########.eeeee######",
		"######.............#",
		"######........######",
		"######........######",
		"#######......#######",
		"#######......#######",
		"#######......#######",
		"#########XX#########",
]


func _textura() -> Texture2D:
	return ARTE


func _filas() -> PackedStringArray:
	return PackedStringArray(FILAS)
