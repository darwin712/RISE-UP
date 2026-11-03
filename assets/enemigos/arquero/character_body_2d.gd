extends CharacterBody2D
@export var escena_bala: PackedScene = preload("res://assets/enemigos/arquero/Bala.tscn") 

@onready var punto_disparo: Marker2D = $PuntoDisparo
@onready var timer_disparo: Timer = $TimerDisparo
@onready var area_contacto: Area2D = $AreaContacto

# Buscamos al jugador al iniciar. Recuerda añadir al jugador al grupo "jugador"
@onready var jugador: Node2D = get_tree().get_first_node_in_group("jugador")

func _ready() -> void:
	timer_disparo.timeout.connect(_on_timer_disparo_timeout)
	# Si no activaste "Autostart" en el Inspector, descomenta la siguiente línea:
	# timer_disparo.start()

func _physics_process(_delta: float) -> void:
	# Si el jugador toca al enemigo, pierde vida
	for cuerpo in area_contacto.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			cuerpo.recibir_dano()

func _on_timer_disparo_timeout() -> void:
	disparar()
	timer_disparo.start() # Reinicia el temporizador si "One Shot" está activado

func disparar() -> void:
	# Si el jugador murió o no existe en la escena, no dispares
	if not is_instance_valid(jugador):
		return

	# Comprobación de seguridad: verifica si olvidaste asignar la escena en el Inspector
	if not escena_bala:
		print("Error: No has asignado ninguna escena de bala al enemigo.")
		return

	# Lado en el que está el jugador: 1 = derecha, -1 = izquierda
	var lado = 1 if jugador.global_position.x > global_position.x else -1
	var direccion = Vector2(lado, 0)

	# Instanciar la bala y añadirla a la escena principal
	var bala = escena_bala.instantiate()
	get_tree().current_scene.add_child(bala)
	
	# Posicionar la bala en el Marker2D del enemigo (espejado según el lado)
	bala.global_position = global_position + Vector2(punto_disparo.position.x * lado, punto_disparo.position.y)

	# Pasar las variables de movimiento a la bala
	if bala.has_method("configurar_direccion"):
		bala.configurar_direccion(direccion)
	else:
		bala.rotation = direccion.angle()
		# Verifica que tu script de la bala tenga declarada la variable 'direccion'
		if "direccion" in bala:
			bala.direccion = direccion
