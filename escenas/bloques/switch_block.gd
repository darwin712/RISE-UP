extends StaticBody2D

@export var texturaActiva: Texture2D
@export var texturaInactiva: Texture2D
@export var estaActivo: bool
@onready var sprite = $Sprite2D
@onready var colision = $CollisionShape2D

func _ready() -> void:
	if estaActivo:
		colision.set_deferred("disabled", false)
		sprite.texture = texturaActiva
	else:
		colision.set_deferred("disabled",true)
		sprite.texture = texturaInactiva


func activar():
	if estaActivo:
		return

	estaActivo = true
	sprite.texture = texturaActiva
	colision.set_deferred("disabled", false)
	
func desactivar():
	if !estaActivo:
		return
	estaActivo =false
	sprite.texture = texturaInactiva
	colision.set_deferred("disabled",true)
