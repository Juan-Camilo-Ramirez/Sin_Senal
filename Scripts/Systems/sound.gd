extends AudioStreamPlayer

func _ready() -> void:
	finished.connect(_al_terminar)
	play()

func _al_terminar() -> void:
	play()   # vuelve a empezar cuando acaba

# Red de seguridad: si por algún motivo no se emite "finished", lo reinicia igual
func _process(_delta: float) -> void:
	if not playing:
		play()
