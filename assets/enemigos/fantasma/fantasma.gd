
extends CharacterBody2D

enum Estado {
	perseguir,
	desaparece,
	reaparece
}
@onready var animacionFantasma: AnimatedSprite2D = %spriteFantasma
@onready var area_contacto: Area2D = $AreaContacto
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var colision_area: CollisionShape2D = $AreaContacto/CollisionShape2D
@onready var jugador = get_tree().get_first_node_in_group("jugador")
@export var vida: int = 3
@export var velocidad: float = 45.0
@export var tp: float = 180.0
var estado = Estado.perseguir
var tiempo_estado: float = 0.0
var tiempo_dano: float = 0.0


func _physics_process(delta: float) -> void:

	tiempo_dano = maxf(0.0, tiempo_dano - delta)
	if not is_instance_valid(jugador):
		velocity = Vector2.ZERO
		return
	match estado:

		Estado.perseguir:

			var direccion = (jugador.global_position - global_position).normalized()

			velocity = direccion * velocidad
			

		Estado.desaparece:

			velocity = Vector2.ZERO
			tiempo_estado -= delta

			if tiempo_estado <= 0:
				var lado = -1.0 if jugador.global_position.x > global_position.x else 1.0
				global_position = jugador.global_position + Vector2(
					lado * tp,
					-25
				)

				colision.set_deferred("disabled", true)
				colision_area.set_deferred("disabled", true)

				visible = false
				estado = Estado.reaparece
				tiempo_estado = 0.35
		Estado.reaparece:

			velocity = Vector2.ZERO
			tiempo_estado -= delta

			if tiempo_estado <= 0:
				visible = true
				colision.set_deferred("disabled", false)
				colision_area.set_deferred("disabled", false)

				estado = Estado.perseguir
				
	if velocity.x > 0:
		animacionFantasma.play("default")
		animacionFantasma.flip_h = false
	elif velocity.x <0:
		animacionFantasma.play("default")
		animacionFantasma.flip_h = true
	
	
	move_and_slide()

	for cuerpo in area_contacto.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador") and tiempo_dano <= 0:
			cuerpo.recibir_dano()
			tiempo_dano = 0.8



func quitar_vida(dano: int) -> void:
	vida -= dano
	estado = Estado.desaparece
	tiempo_estado = 1
	velocity = Vector2.ZERO
	if vida <= 0:
		queue_free()
