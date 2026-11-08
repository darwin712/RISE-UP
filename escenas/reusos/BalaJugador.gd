extends Area2D

@export var velocidad: float = 600.0
@export var dano: int = 1
@export var tiempoVida: float = 2.0
var direccion: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("balas")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(tiempoVida).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("quitar_vida"):
		body.quitar_vida(dano)
	queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ojo"):
		area.get_parent().recibirDisparo()
		queue_free()
