extends RigidBody2D

@export var raycast_jugador: RayCast2D  
@export var raycast_suelo: RayCast2D   
@export var caida: float = 300.0
@export var velocidad_subida: float = 100.0
@export var tiempo_espera: float = 2.0
@export var sprite: AnimatedSprite2D
var posInicial: Vector2
var cayendo: bool = false
var subiendo: bool = false
var esperando: bool = false

func _ready() -> void:
	posInicial = global_position
	freeze = true
	lock_rotation = true

func _physics_process(delta: float) -> void:
	global_position.x = posInicial.x

	#si te mira cae
	if not cayendo and not subiendo and not esperando:
		if raycast_jugador != null and raycast_jugador.is_colliding():
			var col = raycast_jugador.get_collider()
			if col != null and (col.is_in_group("jugador") or col.get_parent().is_in_group("jugador")):
				cayendo = true

	# ve si hay suelo a 10 pixeles
	if cayendo:
		if raycast_suelo != null and raycast_suelo.is_colliding():
			detener_y_esperar()
		else:
			global_position.y += caida * delta

	# sube
	elif subiendo:
		global_position = global_position.move_toward(posInicial, velocidad_subida * delta)
		if global_position == posInicial:
			subiendo = false
			
	if cayendo:
		sprite.play("agresivo")
	else:
		sprite.play("default")

# daño
func _on_area_2d_body_entered(body: Node2D) -> void:
	if cayendo:
		if body.is_in_group("jugador") or body.get_parent().is_in_group("jugador"):
			var jugador = body if body.is_in_group("jugador") else body.get_parent()
			if jugador.has_method("_on_hurtbox_body_entered"):
				jugador._on_hurtbox_body_entered(self)
		
		detener_y_esperar()
#temporizador
func detener_y_esperar() -> void:
	if not esperando:
		cayendo = false
		esperando = true
		await get_tree().create_timer(tiempo_espera).timeout
		esperando = false
		subiendo = true
