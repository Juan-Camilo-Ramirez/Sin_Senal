extends Area2D
## Objeto interactivo (mecánica 3): equipos dañados, mesa de instalación,
## estantería del depósito y mostradores.

## equipos, mesa, estanteria, mostrador_tienda o mostrador_taller.
@export var accion: StringName


const TEXTOS := {
	&"equipos": "Revisar los equipos dañados",
	&"mesa": "Usar la mesa de instalación",
	&"estanteria": "Revisar la estantería",
	&"mostrador_tienda": "Ver el mostrador de Camilo",
	&"mostrador_taller": "Hablar con Don Jorge",
}


func texto_accion() -> String:
	return TEXTOS.get(accion, "Interactuar")


func interactuar() -> void:
	match accion:
		&"equipos":
			# Primera revisión: desbloquea la lista de síntomas (mecánica 7).
			if not GameState.sintomas_desbloqueados:
				await UI.dialogo().mostrar("Aula de sistemas", Dialogos.EQUIPOS)
				GameState.desbloquear_sintomas()
			UI.sintomas().abrir()
		&"mesa":
			await UI.mesa().abrir()
		&"estanteria":
			await UI.mostrador().abrir("Estantería del depósito", Dialogos.ESTANTERIA_DEPOSITO)
		&"mostrador_tienda":
			_hablar_con(&"camilo")
		&"mostrador_taller":
			_hablar_con(&"jorge")


## Los mostradores de la tienda y el taller se atienden con su personaje.
func _hablar_con(id: StringName) -> void:
	var npc := get_tree().get_first_node_in_group(StringName("npc_%s" % id))
	if npc:
		npc.interactuar()
