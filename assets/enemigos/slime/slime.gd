extends CharacterBody2D

@export var vida: int = 2

func quitar_vida(dano: int) -> void:
	if vida <= 0:
		haMuerto.emit()
		queue_free()
		return
	vida -= dano
	animacionSlime.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animacionSlime.modulate = Color.WHITE

@onready var animacionSlime: AnimatedSprite2D = %animacionSlime

@onready var jugador: Node2D = get_tree().get_first_node_in_group("jugador")
@onready var area_contacto: Area2D = $AreaContacto
var velocidad = 30.0
var ultima_posicion_segura := Vector2.ZERO
var tiene_posicion_segura := false
signal haMuerto

func _ready() -> void:
	add_to_group("enemigos")
	floor_snap_length = 4.0

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
	for cuerpo in area_contacto.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			cuerpo.recibir_dano()
	if jugador != null:
		var direccion = (jugador.global_position - global_position).normalized()
		var movimiento_horizontal: float = direccion.x * velocidad
	#	if is_on_floor() and not _hay_suelo_adelante(movimiento_horizontal):
	#		movimiento_horizontal = 0.0
		velocity.x = movimiento_horizontal
	if velocity.x > 0:
		animacionSlime.play("caminar")
		animacionSlime.flip_h = false
	elif velocity.x <0:
		animacionSlime.play("caminar")
		animacionSlime.flip_h = true
	else:
		animacionSlime.play("idle")
	

	move_and_slide()
	#if is_on_floor():
	ultima_posicion_segura = global_position
	tiene_posicion_segura = true
	#elif tiene_posicion_segura and global_position.y > ultima_posicion_segura.y + 10.0:
	#	global_position = ultima_posicion_segura
	#	velocity = Vector2.ZERO


#func _hay_suelo_adelante(movimiento_horizontal: float) -> bool:
	#if is_zero_approx(movimiento_horizontal):
	#	return true
#	var lado := signf(movimiento_horizontal)
#	var desde := global_position + Vector2(lado * 9.0, -2.0)
#	var hasta := desde + Vector2(0.0, 12.0)
#	var consulta := PhysicsRayQueryParameters2D.create(desde, hasta, collision_mask, [get_rid()])
	#consulta.collide_with_areas = false
	#return not get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()


func _on_area_contacto_area_entered(area: Area2D) -> void:
	if area.is_in_group("jugador"):
		area.recibir_dano()
