extends StaticBody2D

@export var raycast: RayCast2D 
var caida: float =200
var posInicial: Vector2
var velocidad_subida: float = 100.0
@export var tiempo_espera: float = 2.0

var cayendo: bool = false
var subiendo: bool = false
var esperando: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	posInicial = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not cayendo and not subiendo and not esperando:
		if raycast != null and raycast.is_colliding():
			var objeto = raycast.get_collider()
			if objeto != null and objeto.is_in_group("jugador"):
				cayendo = true

	# 2. Movimiento de caída manual
	if cayendo:
		global_position.y += caida * delta

	# 3. Regreso paulatino al punto de origen
	elif subiendo:
		global_position = global_position.move_toward(posInicial, velocidad_subida * delta)
		if global_position == posInicial:
			subiendo = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if body.has_method("_on_hurtbox_body_entered"):
			body._on_hurtbox_body_entered(self)
