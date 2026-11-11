extends Area2D
 
var velocidad = 200
@export var animacion: AnimatedSprite2D
func _ready() -> void:
	add_to_group("ataque_jefe")
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(10.0).timeout.connect(queue_free)
	animacion.play()
 
func _physics_process(delta: float) -> void:
	position.y += velocidad * delta
 
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		body.recibir_dano()
	queue_free()
 
