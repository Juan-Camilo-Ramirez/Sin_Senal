class_name MapaBase
extends Node2D
## Base común del pueblo y de los interiores: crea personajes y objetos a
## partir de los marcadores del mapa y coloca al jugador.

const ESCENA_PUERTA := preload("res://Scenes/World/Puerta.tscn")
const ESCENA_NPC := preload("res://Scenes/NPCs/NPC.tscn")
const ESCENA_OBJETO := preload("res://Scenes/World/ObjetoInteractivo.tscn")
const RUTA_PUEBLO := "res://Scenes/World/Pueblo.tscn"

## Personajes (sección 5).
const NPCS := {
	"S": &"sofia", "Q": &"pedro", "M": &"marta", "H": &"hernan",
	"L": &"luz", "C": &"camilo", "G": &"jorge",
}
## Objetos interactivos (mecánica 3).
const OBJETOS := {
	"k": &"equipos",          # equipos dañados del aula (desbloquean síntomas)
	"i": &"mesa",             # mesa de instalación
	"e": &"estanteria",       # estantería del depósito
	"y": &"mostrador_tienda", # mostrador de Camilo
	"z": &"mostrador_taller", # mostrador de Don Jorge
}

## Altura de la franja del HUD sobre la pantalla de juego.
const HUD_ALTO := 64
## Pantalla de juego visible bajo el HUD.
const VISTA := Vector2(256, 176)

@onready var capa: TileMapLayer = $Suelo
@onready var entidades: Node2D = $Entidades
@onready var jugador: CharacterBody2D = $Player
@onready var camara: Camera2D = $Camara

var _inicio := Vector2.ZERO


func _crear_marcador(m: Dictionary) -> void:
	var ch: String = m.char
	var pos := ConstructorMapa.centro(m.celda)
	if NPCS.has(ch):
		var npc = ESCENA_NPC.instantiate()
		npc.personaje = NPCS[ch]
		npc.position = pos
		entidades.add_child(npc)
	elif OBJETOS.has(ch):
		var obj = ESCENA_OBJETO.instantiate()
		obj.accion = OBJETOS[ch]
		obj.position = pos
		entidades.add_child(obj)
	elif ch == "@":
		_inicio = pos


func _crear_puerta(pos: Vector2, destino: String, salida: Vector2, regreso := Vector2.INF, texto := "Entrar") -> void:
	var puerta = ESCENA_PUERTA.instantiate()
	puerta.position = pos
	puerta.escena_destino = destino
	puerta.posicion_salida = salida
	puerta.posicion_regreso = regreso
	puerta.texto = texto
	entidades.add_child(puerta)


## Posición de la cámara (esquina superior izquierda) para seguir al jugador
## sin salirse de `zona`. Si la zona es más chica que la vista, la centra.
func _encuadre(zona: Rect2, objetivo: Vector2) -> Vector2:
	var pos := Vector2.ZERO
	for eje in 2:
		if zona.size[eje] <= VISTA[eje]:
			pos[eje] = zona.position[eje] + (zona.size[eje] - VISTA[eje]) / 2.0
		else:
			pos[eje] = clampf(objetivo[eje] - VISTA[eje] / 2.0,
				zona.position[eje], zona.end[eje] - VISTA[eje])
	return pos


## Coloca al jugador en la posición de llegada (puerta) o en el inicio.
func _colocar_jugador() -> void:
	if GameState.posicion_entrada != Vector2.INF:
		jugador.position = GameState.posicion_entrada
		GameState.posicion_entrada = Vector2.INF
	else:
		jugador.position = _inicio

