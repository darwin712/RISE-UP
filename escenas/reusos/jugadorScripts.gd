extends CharacterBody2D

const ARMA_BASE = preload("res://assets/armas/Tier1pMadera/tier1.tscn")

var vida = 3
@export var alcanceRecoger: float = 42.0
var armaBase
var armaActual
var tiempoFlote: float = 0.0
var fuerzaAscenso: float = 0.0
var tiempo_invulnerable_ms = 1500
var invulnerable_hasta = 0

@onready var hurtbox: Area2D 
@onready var sfxJugador: AudioStreamPlayer2D = %sfxJugador
@export var animacion: AnimatedSprite2D

@export var CollisionPersonaje: CollisionObject2D
@export var CollisionPersonajeAgachado: CollisionObject2D


var velocidadSalto = -390 
var velocidadDobleSalto = -300
var velocidad: float = 185.72
var aceleracion = 200
var velocidadDeDesliz = 32
var last_wall: Vector2 = Vector2.ZERO
var wall_normal
@export var velocidadWalljump: Vector2 = Vector2(300.0, -350.0)
@export var empujarDano: Vector2 = Vector2(150.0,-275.0)
var agachado: bool 

var dobleSalto: bool = false

const coyoteTiempo: float = 0.2
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

@export var saltoSFX: AudioStream
@export var danoSFX: AudioStream
@export var walljumpSFX: AudioStream

var en_pared: bool = is_on_wall_only()


func _ready() -> void:
	add_to_group("jugador")
	posInicial = global_position
	posCheckpoint = posInicial
	add_to_group("jugador")
	print("Vidas restantes: ", vida)
	armaBase = ARMA_BASE.instantiate()
	add_child(armaBase)
	armaActual = armaBase
	

func flotar(segundos: float, fuerza: float = 0.0) -> void:
	tiempoFlote = segundos
	fuerzaAscenso = fuerza
	
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
	get_tree().change_scene_to_file("res://escenas/Menu/menu.tscn")

func reproducir_sfx(sonido: AudioStream, volumen: float) -> void:
	if sonido != null:
		sfxJugador.stream = sonido
		sfxJugador.volume_db = volumen
		sfxJugador.play()

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
	reproducir_sfx(danoSFX, -20)
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
		
		# Walljump 
		if en_pared or EstaPared:
			
			velocity.x = wall_normal.x * velocidadWalljump.x
			
			velocity.y = velocidadWalljump.y
			reproducir_sfx(walljumpSFX,-10)
			cronoBuffer = 0.0
			cronoBloqueo = tiempoPared
			# Salto 
		elif crono_coyote > 0.0 or dobleSalto:
			reproducir_sfx(saltoSFX,0)
			velocity.y = velocidadSalto 
			crono_coyote = 0.0 
			cronoBuffer = 0.0
			dobleSalto = false
		
		
		
			

	

		
	
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
	if tiempoFlote > 0.0:
		tiempoFlote -= delta
		velocity.y = -fuerzaAscenso

	manejar_armas()
	move_and_slide()

func manejar_armas() -> void:
	var direccion := Vector2.LEFT if animacion.flip_h else Vector2.RIGHT
	armaActual.position = Vector2(10 * direccion.x, -14)
	if Input.is_action_just_pressed("agarrar"):
		recoger_arma()
	if Input.is_action_pressed("shoot"):
		armaActual.disparar(direccion)
		if armaActual != armaBase and armaActual.balas <= 0:
			armaActual.queue_free()
			armaActual = armaBase
	
func recoger_arma() -> void:
	var cercana = null
	var menor := alcanceRecoger
	for arma in get_tree().get_nodes_in_group("arma_suelo"):
		var distancia := global_position.distance_to(arma.global_position)
		if distancia < menor:
			menor = distancia
			cercana = arma
	if cercana == null:
		return
	if armaActual != armaBase:
		armaActual.queue_free()
	cercana.remove_from_group("arma_suelo")
	cercana.reparent(self, false)
	armaActual = cercana


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if Time.get_ticks_msec() < invulnerable_hasta:
		return
	recibir_dano()
	if haMuerto:
		return
	regresarCheckpoint()





func _on_hurtbox_area_entered(area: Area2D) -> void:
		pass
	
	
