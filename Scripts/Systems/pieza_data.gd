class_name PiezaData
extends Resource
## Datos de una pieza del juego: una de las 6 necesarias o una de las 6 trampas
## (secciones 8.1, 8.2 y 15). La mesa de instalación lee estos datos para
## aceptar o rechazar la pieza.

## Identificador único (por ejemplo, &"regulador" o &"cable_coaxial").
@export var id: StringName
## Nombre completo, como aparece en el documento.
@export var nombre: String
## Texto corto para la casilla del inventario (placeholder sin arte).
@export var nombre_corto: String
## true = una de las 6 piezas necesarias; false = pieza trampa.
@export var necesaria: bool = false
## Para qué sirve la pieza. En las trampas es «Qué explica el juego» (8.2).
@export_multiline var funcion: String
## En las trampas: la pista que da Marta, solo en el aula (8.2).
## En las necesarias: lo que dice Marta si se coloca en un lugar equivocado
## («explica dónde va», 9.9).
@export_multiline var pista: String
## Cápsula educativa (8.1). Vacía en las trampas.
@export_multiline var capsula: String
## Dónde se consigue (solo informativo).
@export var donde: String
## Paso de instalación al que pertenece (ver GameState.ORDEN_INSTALACION).
## Vacío en las trampas: no tienen lugar en la mesa.
@export var paso: StringName
## Ícono de 32 × 32 (Assets/Items/Iconos/). El original está en
## Assets/Items/Originales/.
@export var icono: Texture2D
## Color de respaldo si falta el ícono.
@export var color: Color = Color.WHITE


func es_trampa() -> bool:
	return not necesaria
