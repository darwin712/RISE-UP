extends CharacterBody2D
@export var animacion: AnimatedSprite2D
var velocidadSalto = -330 
var velocidad: float = 200.0
var aceleracion = 200
var velocidadDeDesliz = 32
var last_wall: Vector2 = Vector2.ZERO
const Coyote_tiempo: float = 0.25
var crono_coyote: float = 0.0

func DeslizarPared():
	if !is_on_floor():
		var wall_normal = get_wall_normal()
		if is_on_wall() and velocity.y > 0 and abs(get_wall_normal().x) > 0.9:
			velocity.y = min(velocity.y, velocidadDeDesliz)
	else: 
		last_wall = Vector2.ZERO
	



func _physics_process(delta: float):
	#cronometro
	if is_on_floor():
		crono_coyote = Coyote_tiempo
	else:
		crono_coyote -= delta

	#animaciones
	if not is_on_floor():
		animacion.play("saltar")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("default")
	
	#gravedad
	velocity += get_gravity() * delta 
	if !Input.is_action_pressed("Saltar") and velocity.y < 0:
		velocity.y = 0
		
	#salto
	if Input.is_action_pressed("Saltar"):
		if crono_coyote > 0.0:
			velocity.y = velocidadSalto 
			crono_coyote = 0.0 
	
	# Movimiento horizontal
	var direccion := Input.get_axis("Mover_izquierda", "Mover_derecha")
	if direccion: 
		velocity.x = direccion * velocidad 
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
	
	if direccion == 1.0:
		animacion.flip_h = false
	elif direccion == -1.0:
		animacion.flip_h = true
	
	DeslizarPared()
	move_and_slide()
