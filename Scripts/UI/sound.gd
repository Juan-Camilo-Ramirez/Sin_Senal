extends AudioStreamPlayer

func _ready() -> void:
	finished.connect(play)   # cuando termina, vuelve a empezar
	play()
