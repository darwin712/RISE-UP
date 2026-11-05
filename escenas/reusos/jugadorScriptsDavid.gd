extends CharacterBody2D
@export var animacion: AnimatedSprite2D
@export var CollisionPersonaje: CollisionObject2D
@export var CollisionPersonajeAgachado: CollisionObject2D

@onready var hurtbox: Area2D 

var velocidadSalto = -390 
var velocidadDobleSalto = -300
var velocidad: float = 200.0
var aceleracion = 200
var velocidadDeDesliz = 32
var last_wall: Vector2 = Vector2.ZERO
var wall_normal
@export var velocidadWalljump: Vector2 = Vector2(300.0, -350.0)
var agachado: bool 


const coyoteTiempo: float = 0.25
const tiempoPared: float = 0.4
const tiempoBuffer: float = 0.2


var crono_coyote: float = 0.0
var cronoBloqueo: float = 0.0
var cronoBuffer: float = 0.0

var  EstaPared: bool = false
var pausa: bool=false

var posInicial: Vector2


var en_pared: bool = is_on_wall_only()


func _ready() -> void:
	posInicial = global_position

func limitarPantalla():
	pass

func respawn():
	self.global_position = posInicial
	velocity = Vector2.ZERO
	
	

func morir():
	animacion.play("muerte")
	pausa=true
	await get_tree().create_timer(0.3).timeout
	pausa = false
	respawn()

func detectarObstaculoDano():
	if hurtbox.has_overlapping_bodies():
		respawn()

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
	



func _physics_process(delta: float):
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
	if !Input.is_action_pressed("Saltar") and velocity.y < 0:
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
