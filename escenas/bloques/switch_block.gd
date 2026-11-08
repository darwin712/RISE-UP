extends StaticBody2D

@export var texturaActiva: Texture2D

@onready var sprite = $Sprite2D
@onready var colision = $CollisionShape2D

var estaActivo = false

func activar():
	if estaActivo:
		return

	estaActivo = true
	sprite.texture = texturaActiva
	colision.set_deferred("disabled", false)
