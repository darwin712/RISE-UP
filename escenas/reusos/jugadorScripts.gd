extends CharacterBody2D

var vida = 3
var tiempo_invulnerable_ms = 1500
var invulnerable_hasta = 0

@onready var hurtbox: Area2D 

@export var animacion: AnimatedSprite2D

@export var CollisionPersonaje: CollisionObject2D
@export var CollisionPersonajeAgachado: CollisionObject2D


var velocidadSalto = -390 
var velocidadDobleSalto = -300
var velocidad: float = 200.0
var aceleracion = 200
var velocidadDeDesliz = 32
var last_wall: Vector2 = Vector2.ZERO
var wall_normal
@export var velocidadWalljump: Vector2 = Vector2(300.0, -350.0)
@export var empujarDano: Vector2 = Vector2(150.0,-275.0)
var agachado: bool 


const coyoteTiempo: float = 0.25
const tiempoPared: float = 0.4
const tiempoBuffer: float = 0.2


var crono_coyote: float = 0.0
var cronoBloqueo: float = 0.0
var cronoBuffer: float = 0.0

var  EstaPared: bool = false
var pausa: bool=false
var haMuerto: bool = false

var posInicial: Vector2
var posCheckpoint: Vector2
var ignorarConexionesHasta: int = 0


var en_pared: bool = is_on_wall_only()


func _ready() -> void:
	add_to_group("jugador")
	posInicial = global_position
	posCheckpoint = posInicial
	add_to_group("jugador")
	print("Vidas restantes: ", vida)
	

	
func regresarCheckpoint():
	ignorarConexionesHasta = Time.get_ticks_msec() + 300
	self.global_position = posCheckpoint
	velocity = Vector2.ZERO
	
	
func morir():
	if haMuerto:
		return
	
	haMuerto = true
	velocity = Vector2.ZERO
	invulnerable_hasta = 0
	animacion.modulate = Color.WHITE
	animacion.play("muerte")
	await get_tree().create_timer(1.10).timeout
	get_tree().reload_current_scene()

func DeslizarPared():
	if !is_on_floor():
		wall_normal = get_wall_normal()
		en_pared = is_on_wall_only()
		if is_on_wall() and velocity.y > 0 and abs(get_wall_normal().x) > 0.9:
			velocity.y = min(velocity.y, velocidadDeDesliz)
			EstaPared = true
			animacion.play("slide")
		else:
			EstaPared = false
	else: 
		last_wall = Vector2.ZERO
		EstaPared = false
		en_pared = false
	
	
	
func recibir_dano() -> void:
	var ahora = Time.get_ticks_msec()
	if ahora < invulnerable_hasta:
		return
		
	invulnerable_hasta = ahora + tiempo_invulnerable_ms
	
	#empuje hacia atras
	var direccion_x: float = 0.0
	if velocity.x != 0:
		direccion_x = sign(velocity.x) 
	else:
		direccion_x = -1.0 if animacion.flip_h else 1.0
	
	
	velocity.x = -direccion_x * empujarDano.x
	velocity.y = empujarDano.y
	
	cronoBloqueo = 0.5 
	#lo del jovan
	vida -= 1
	print("Vidas restantes: ", vida)
	if vida <= 0:
		morir()
		print("Has muerto!")
	else:
		parpadear_invulnerabilidad()
		
func parpadear_invulnerabilidad() -> void:
	
	while Time.get_ticks_msec() < invulnerable_hasta:
		animacion.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout 
		
		animacion.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
	animacion.modulate = Color.WHITE
	
	

func _physics_process(delta: float):
	if haMuerto:
		velocity = Vector2.ZERO
		return
	
	var direccion := Input.get_axis("Mover_izquierda", "Mover_derecha")
	#cronometro
	if is_on_floor():
		crono_coyote = coyoteTiempo
	else:
		crono_coyote -= delta

	if Input.is_action_just_pressed("Saltar"):
		cronoBuffer = tiempoBuffer
	else:
		cronoBuffer -= delta

	cronoBloqueo -= delta
		
	if Input.is_action_just_pressed("Saltar"):
		cronoBloqueo = tiempoPared
	else:
		cronoBloqueo -= delta

	cronoBloqueo -= delta

	DeslizarPared()

	#animaciones
	if not is_on_floor() and !EstaPared:
		animacion.play("saltar")
		animacion.offset.y=-1
	elif velocity.x != 0:
		animacion.play("correr")
	elif agachado:
		animacion.play("agachado")
	elif EstaPared and is_on_wall_only():
		animacion.play("slide")
	elif Input.is_action_pressed("agacharse"):
		animacion.play("agachado")
		animacion.offset.y = 5
		direccion = 0
	else:
		animacion.play("default")
		animacion.offset.y = 0
	
	#gravedad
	if pausa:
		velocity = Vector2.ZERO
		return
	velocity += get_gravity() * delta 
	if !Input.is_action_pressed("Saltar") and velocity.y < 0 and cronoBloqueo <= 0.0:
		velocity.y = 0
		
	#salto
	if cronoBuffer > 0.0:
		# Salto 
		if crono_coyote > 0.0:
			velocity.y = velocidadSalto 
			crono_coyote = 0.0 
			cronoBuffer = 0.0
		# Walljump 
		elif en_pared or EstaPared:
			velocity.x = wall_normal.x * velocidadWalljump.x
			velocity.y = velocidadWalljump.y
			cronoBuffer = 0.0
			cronoBloqueo = tiempoPared
		
			

	

		
	
	# Movimiento horizontal
	if cronoBloqueo <= 0.0:
		if direccion: 
			velocity.x = direccion * velocidad 
		else:
			velocity.x = move_toward(velocity.x, 0, velocidad)
		
		if direccion == 1.0:
			animacion.flip_h = false
		elif direccion == -1.0:
			animacion.flip_h = true
	
	
	move_and_slide()





func _on_hurtbox_body_entered(body: Node2D) -> void:
	if Time.get_ticks_msec() < invulnerable_hasta:
		return
	recibir_dano()
	if haMuerto:
		return
	regresarCheckpoint()





func _on_hurtbox_area_entered(area: Area2D) -> void:
		pass
	
	
