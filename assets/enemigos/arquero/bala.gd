extends Area2D

var velocidad = 400
var direccion = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(4.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		body.recibir_dano()
		queue_free() # Destruye la bala
	else:
		# Si choca contra una pared u otro objeto
		queue_free()
