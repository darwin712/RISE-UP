extends Node2D

@export var duracion: float = 10.0
@export var acension: float = 60.0

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("flotar"):
		body.flotar(duracion, acension)
		$Area2D.set_deferred("monitoring", false)
		hide()
		await get_tree().create_timer(2.27).timeout
		show()
		$Area2D.set_deferred("monitoring", true)
