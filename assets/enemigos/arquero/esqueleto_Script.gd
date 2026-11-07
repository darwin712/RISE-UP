extends CharacterBody2D
@export var escena_bala: PackedScene = preload("res://assets/enemigos/arquero/Bala.tscn") 

@onready var animacionEsqueleto: AnimatedSprite2D = %AnimacionEsqueleto
@onready var punto_disparo: Marker2D = $PuntoDisparo
@onready var timer_disparo: Timer = $TimerDisparo
@onready var area_contacto: Area2D = $AreaContacto

@onready var jugador: Node2D = get_tree().get_first_node_in_group("jugador")

func _ready() -> void:
	timer_disparo.timeout.connect(_on_timer_disparo_timeout)

		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	for cuerpo in area_contacto.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			cuerpo.recibir_dano()
	if jugador != null:
		animacionEsqueleto.play("default")
		animacionEsqueleto.flip_h = jugador.global_position.x < global_position.x
		var direccion = (jugador.global_position - global_position).normalized()

func _on_timer_disparo_timeout() -> void:
	disparar()
	timer_disparo.start()
	
func disparar() -> void:
	if not is_instance_valid(jugador):
		return
	if not escena_bala:
		print("E")
		return
	var ladoX = 0.75 if jugador.global_position.x > global_position.x else -1
	var ladoY = 0.75 if jugador.global_position.y > global_position.y else -1
	var direccion = Vector2(ladoX, ladoY).normalized()

	var bala = escena_bala.instantiate()
	get_tree().current_scene.add_child(bala)
	
	bala.global_position = global_position + Vector2(punto_disparo.position.x * ladoX, punto_disparo.position.y * ladoY)

	if bala.has_method("configurar_direccion"):
		bala.configurar_direccion(direccion)
	else:
		bala.rotation = direccion.angle()
		if "direccion" in bala:
			bala.direccion = direccion

func _on_area_contacto_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
