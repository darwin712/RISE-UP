extends Camera2D

const BASE := Vector2(480, 270)

func _ready():
	get_viewport().size_changed.connect(_ajustar)
	_ajustar()

func _ajustar():
	var tam := get_viewport_rect().size
	var z = max(tam.x / BASE.x, tam.y / BASE.y)
	zoom = Vector2(z, z)
