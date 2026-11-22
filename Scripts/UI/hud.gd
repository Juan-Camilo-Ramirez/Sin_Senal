extends CanvasLayer
## HUD (sección 14): piezas encontradas (0/6), personas ayudadas (0/4),
## inventario de 6 casillas y acceso a la lista de síntomas.
## Además: el objetivo actual (pista paso a paso) bajo la franja superior y el
## aviso de la tecla de interacción en la parte de abajo.

@onready var piezas: Label = $Banda/Piezas
@onready var ayudas: Label = $Banda/Ayudas
@onready var aviso_sintomas: Label = $Banda/AvisoSintomas
@onready var objetivo: PanelContainer = $Objetivo
@onready var objetivo_texto: Label = $Objetivo/Texto
@onready var aviso: PanelContainer = $AvisoAccion
@onready var aviso_texto: Label = $AvisoAccion/Texto

var _ultimo_objetivo := ""


func _ready() -> void:
	GameState.piezas_encontradas_cambiadas.connect(func(_n: int): _actualizar())
	GameState.ayudas_cambiadas.connect(func(_n: int): _actualizar())
	GameState.paso_instalacion_cambiado.connect(func(_n: int): _actualizar())
	GameState.sintomas_desbloqueados_cambiado.connect(_actualizar)
	GameState.inventario_cambiado.connect(_actualizar)
	GameState.banderas_cambiadas.connect(_actualizar)
	GameState.juego_terminado.connect(_actualizar)
	GameState.aviso_accion_cambiado.connect(_on_aviso)
	aviso.hide()
	_actualizar()


func _actualizar() -> void:
	piezas.text = "Piezas: %d/%d" % [GameState.piezas_encontradas.size(), GameState.TOTAL_PIEZAS]
	ayudas.text = "Ayudas: %d/%d" % [GameState.ayudas.size(), GameState.TOTAL_AYUDAS]
	aviso_sintomas.visible = GameState.sintomas_desbloqueados
	var texto := GameState.objetivo_actual()
	objetivo.visible = not texto.is_empty()
	if texto != _ultimo_objetivo:
		_ultimo_objetivo = texto
		objetivo_texto.text = "Objetivo: " + texto
		# Destello para que el jugador note el objetivo nuevo.
		objetivo.modulate = Color(1.8, 1.6, 0.6)
		create_tween().tween_property(objetivo, "modulate", Color.WHITE, 1.2)


func _on_aviso(texto: String) -> void:
	aviso.visible = not texto.is_empty()
	aviso_texto.text = texto
