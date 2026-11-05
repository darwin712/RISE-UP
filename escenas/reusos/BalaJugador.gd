extends Area2D

@export var velocidad: float = 600.0
var direccion: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		body.recibir_daño(1) 
	queue_free() 

func _on_screen_exited() -> void:
	queue_free()
