extends Node2D

const ZOOM_MAX = 2.5
const ZOOM_MIN = 0.7
const ZOOM_STEP = 0.1

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("zoom_up") or Input.is_action_just_released("zoom_up"):
		zoomMais()
	elif Input.is_action_pressed("zoom_down") or Input.is_action_just_released("zoom_down"):
		zoomMenos()

func zoomMais():
	if $Personagem/Camera2D.get_zoom().x >= ZOOM_MIN:
			$Personagem/Camera2D.set_zoom($Personagem/Camera2D.get_zoom() - Vector2(ZOOM_STEP, ZOOM_STEP))

func zoomMenos():
	if $Personagem/Camera2D.get_zoom().x <= ZOOM_MAX:
			$Personagem/Camera2D.set_zoom($Personagem/Camera2D.get_zoom() + Vector2(ZOOM_STEP, ZOOM_STEP))
