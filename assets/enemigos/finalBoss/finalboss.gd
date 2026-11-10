extends CharacterBody2D
@export var vida: int = 90
@export var escena_fuego: PackedScene = preload("res://assets/enemigos/finalBoss/fuego.tscn")
@export var escena_magia: PackedScene = preload("res://assets/enemigos/finalBoss/magia.tscn")
@export var salaFase2: PackedScene = preload("res://escenas/Salas/Nivel0-Prototipo/final002.tscn")
@export var salaFase3: PackedScene = preload("res://escenas/Salas/Nivel0-Prototipo/final003.tscn")
@export var escena_ganaste: PackedScene = preload("res://escenas/UI/pantalla_Ganaste.tscn")
 
@onready var area_contacto: Area2D = $AreaContacto
@onready var timer_fuego: Timer = $TimerFuego
@onready var timer_magia: Timer = $TimerMagia
 
@onready var jugador: Node2D = get_tree().get_first_node_in_group("jugador")
 
var ataqueFuego = 15 #Segundos rese CaeVertical
var velocidadFuegito = 50
var ataqueMagia = 5 #Segundos reset Horizontal
var velocidadMagia = 150 #Van de a 4
 
var fase2 = false #vida <= 80 - (slimes)
var fase3 = false #vida <= 40  (persecucion)

var primerFuego = 5.0
var primerMagia = 2.0
 
#Esto se lo pedi a claude para no copiar 1 a 1 las coords
var patronFuego = [
	Vector2(47, -68),  Vector2(99, -106),
	Vector2(155, -153), Vector2(46, -200),
	Vector2(76, -226), Vector2(73, -269),
	Vector2(184, -106), Vector2(128, -68),
	Vector2(76, -226), Vector2(73, -269),
	Vector2(184, -106), Vector2(128, -68),
	Vector2(276, -226), Vector2(473, -269),
	Vector2(384, -106), Vector2(428, -68),
	Vector2(376, -226), Vector2(373, -269),
	Vector2(300, -106), Vector2(300, -68),
]

var patronMagia = [
	Vector2(550, 239), Vector2(550, 227), Vector2(650, 219), Vector2(650, 209),
	Vector2(750, 237), Vector2(750, 225), Vector2(850, 217), Vector2(850, 207),
	Vector2(1050, 337), Vector2(1050, 325)
]


 
 
func _ready() -> void:
	timer_fuego.timeout.connect(_on_timer_fuego_timeout)
	timer_magia.timeout.connect(_on_timer_magia_timeout)
	timer_fuego.start(primerFuego)
	timer_magia.start(primerMagia)
 
 
func _physics_process(delta: float) -> void: 
	if not is_on_floor():
		velocity += get_gravity() * delta
	for cuerpo in area_contacto.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			cuerpo.recibir_dano()
			
	#gracias a david se quito las fases
	#HAN VUELTO! (Pero no se ni que trate de hacer aca)
	#if vida <= 75 and not fase2: #basicamente envia al jugador a otra pantalla por 60 segundos si llega a 60 vida
	#	fase2 = true
	
	#if vida <= 40 and not fase3: #lo mismo pero a otra pantalla 'final003' 
	#	fase3 = true
		
	 
	move_and_slide()
 
 
func quitar_vida(dano: int) -> void:
	vida -= dano
	if vida <= 0:
		morir()
	elif vida <= 80 and not fase2:
		fase2 = true
		enviarASala(salaFase2)
	elif vida <= 40 and not fase3:
		fase3 = true
		enviarASala(salaFase3)

func enviarASala(sala: PackedScene) -> void:
	get_tree().get_first_node_in_group("main").enviarASalaEspecial(sala)
 
func morir() -> void:
	timer_fuego.stop()
	timer_magia.stop()
	get_tree().call_group("ataque_jefe", "queue_free")
	print("Jefe derrotado")
	var pantalla = escena_ganaste.instantiate()
	get_tree().current_scene.add_child(pantalla)
	pantalla.mostrar()
	get_parent().queue_free()
 
 
func _on_timer_fuego_timeout() -> void:
	lanzar_fuego()
	timer_fuego.start(ataqueFuego)
 
func _on_timer_magia_timeout() -> void:
	lanzar_magia()
	timer_magia.start(ataqueMagia)
 
func lanzar_fuego() -> void:
	var sala = get_parent().get_parent()
	for pos in patronFuego:
		var fuego = escena_fuego.instantiate()
		fuego.velocidad = velocidadFuegito
		sala.add_child(fuego)
		fuego.position = pos
 
func lanzar_magia() -> void:
	var sala = get_parent().get_parent()
	for pos in patronMagia:
		var magia = escena_magia.instantiate()
		magia.velocidad = velocidadMagia
		magia.direccion = Vector2.LEFT
		sala.add_child(magia)
		magia.position = pos
