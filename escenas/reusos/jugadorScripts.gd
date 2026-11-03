extends CharacterBody2D
var vida = 3
var tiempo_invulnerable_ms = 1000
var invulnerable_hasta = 0

@onready var animacion: AnimatedSprite2D = %animacion
@export var gravedad: float = 1300.0
@export var velocidadMax: float = 180.0
@export var velocidadSalto: float = -360.0
@export var velocidadCaidaMax: float = 320.0
@export var velocidadCimaSalto: float = 40.0
@export var velocidadDeslizar: float = 40.0
@export var velocidadWalljump: Vector2 = Vector2(200.0, -320.0)
@export var aceleracionSuelo: float = 1800.0
@export var aceleracionAire: float = 1100.0
@export var friccionSuelo: float = 1600.0
@export var friccionAire: float = 600.0
@export var corteSalto: float = 0.5


const bloqueoPared: float = 0.15
const tiempoCoyote: float = 0.1
const tiempoBuffer: float = 0.1

var cronoCoyote: float = 0.0
var cronoBuffer: float = 0.0
var cronoBloqueo: float = 0.0

var limite_izquierdo: float = 0.0
var limite_derecho: float = 480.0
var limite_superior: float = 0.0
var limite_inferior: float = 270.0

var mitad_ancho: float = 8.0
var mitad_alto: float = 8.0

var posicion_inicial: Vector2
	
func _ready():
	posicion_inicial = global_position
	add_to_group("jugador")

func _physics_process(delta: float):
	var direccion: float = Input.get_axis("Mover_izquierda", "Mover_derecha")

	#CRONOMETROS
	if is_on_floor():
		cronoCoyote = tiempoCoyote
	else:
		cronoCoyote -= delta

	if Input.is_action_just_pressed("Saltar"):
		cronoBuffer = tiempoBuffer
	else:
		cronoBuffer -= delta

	cronoBloqueo -= delta

	#GRAVEDAD
	var g: float = gravedad
	if Input.is_action_pressed("Saltar") and abs(velocity.y) < velocidadCimaSalto:
		g *= 0.5
	velocity.y = min(velocity.y + g * delta, velocidadCaidaMax)

	#DESLIZAR
	var en_pared: bool = is_on_wall_only()
	var normal_pared: Vector2 = get_wall_normal()
	if en_pared and velocity.y > 0.0 and direccion == -sign(normal_pared.x):
		velocity.y = min(velocity.y, velocidadDeslizar)

	#SALTOS
	if cronoBuffer > 0.0 and cronoCoyote > 0.0:
		velocity.y = velocidadSalto
		cronoBuffer = 0.0
		cronoCoyote = 0.0
	elif cronoBuffer > 0.0 and en_pared:
		velocity.x = normal_pared.x * velocidadWalljump.x
		velocity.y = velocidadWalljump.y
		cronoBuffer = 0.0
		cronoBloqueo = bloqueoPared

	#Salto variable
	if Input.is_action_just_released("Saltar") and velocity.y < 0.0:
		velocity.y *= corteSalto

	#ACELERACION
	if cronoBloqueo <= 0.0:
		var aceleracion: float = aceleracionSuelo if is_on_floor() else aceleracionAire
		var friccion: float = friccionSuelo if is_on_floor() else friccionAire
		if direccion != 0.0:
			velocity.x = move_toward(velocity.x, direccion * velocidadMax, aceleracion * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friccion * delta)

	#ANIMACIONES
	if direccion != 0.0 and cronoBloqueo <= 0.0:
		animacion.flip_h = direccion < 0.0

	if not is_on_floor():
		animacion.play("saltar")
	elif abs(velocity.x) > 1.0:
		animacion.play("correr")
	else:
		animacion.play("default")

	move_and_slide()
	limitarPantalla()

func limitarPantalla():
	global_position.x = clamp(global_position.x,limite_izquierdo + mitad_ancho,limite_derecho - mitad_ancho)

	if global_position.y < limite_superior + mitad_alto:
		global_position.y = limite_superior + mitad_alto
		velocity.y = max(velocity.y, 0)

	if global_position.y > limite_inferior + mitad_alto:
		respawnear()

func respawnear():
	global_position = posicion_inicial
	velocity = Vector2.ZERO
	
	
func recibir_dano() -> void:
	var ahora = Time.get_ticks_msec()
	if ahora < invulnerable_hasta:
		return
	invulnerable_hasta = ahora + tiempo_invulnerable_ms
	vida -= 1
	print("Ur life", vida)
	if vida <= 0:
		#Aca se reinicia
		get_tree().reload_current_scene()
