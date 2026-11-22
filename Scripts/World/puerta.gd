class_name Puerta
extends Area2D
## Puerta interactiva (sección 15 «Puertas»): un Area2D que guarda la escena de
## destino y la posición de salida. Se abre al acercarse y pulsar el botón de
## acción (regla 6.3); scene_game hace el fundido a negro.

## Escena que se carga al cruzar la puerta.
@export_file("*.tscn") var escena_destino: String
## Dónde aparece el jugador al otro lado (INF = la entrada de la escena).
@export var posicion_salida := Vector2.INF
## Solo en las puertas del pueblo: dónde reaparece el jugador al salir del
## interior (frente a esta puerta, por fuera).
@export var posicion_regreso := Vector2.INF
## Texto del aviso de interacción («[E] Entrar a la escuela»).
@export var texto := "Entrar"


func texto_accion() -> String:
	return texto


func interactuar() -> void:
	if posicion_regreso != Vector2.INF:
		GameState.posicion_regreso = posicion_regreso
	GameState.solicitar_cambio_escena(escena_destino, posicion_salida)
