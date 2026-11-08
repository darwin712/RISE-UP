extends CharacterBody2D

@export var vida: int = 2

func quitar_vida(dano: int) -> void:
	vida -= dano
	if vida <= 0:
		queue_free()

@onready var animacionSlime: AnimatedSprite2D = %animacionSlime

@onready var jugador: Node2D = get_tree().get_first_node_in_group("jugador")
@onready var area_contacto: Area2D = $AreaContacto
var velocidad = 30.0

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
	for cuerpo in area_contacto.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			cuerpo.recibir_dano()
	if jugador != null:
		var direccion = (jugador.global_position - global_position).normalized()

		velocity.x = direccion.x * velocidad
	if velocity.x > 0:
		animacionSlime.play("caminar")
		animacionSlime.flip_h = false
	elif velocity.x <0:
		animacionSlime.play("caminar")
		animacionSlime.flip_h = true
	else:
		animacionSlime.play("idle")
	

	move_and_slide()


func _on_area_contacto_area_entered(area: Area2D) -> void:
	if area.is_in_group("jugador"):
		area.recibir_dano()
