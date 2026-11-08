extends Node2D
 
@export var escena_bala: PackedScene = preload("res://escenas/reusos/BalaJugador.tscn")
@export var balasM: int = 3
@export var tiempoEntreDis: float = 3.0
@export var tiempo_cooldown: float = 10.0
 
var balas: int = 3
var espera_disparo: float = 0.0
var espera_recarga: float = 0.0
 
func _ready() -> void:
	balas = balasM
 
func _process(delta: float) -> void:
	if espera_disparo > 0.0:
		espera_disparo -= delta
	if espera_recarga > 0.0:
		espera_recarga -= delta
		if espera_recarga <= 0.0:
			balas = balasM 
 
func disparar(direccion: Vector2) -> void:
	if espera_recarga > 0.0 or espera_disparo > 0.0:
		return
	var bala = escena_bala.instantiate()
	bala.global_position = global_position
	bala.direccion = direccion
	bala.rotation = direccion.angle()
	get_tree().current_scene.add_child(bala)
 	
	balas -= 1
	print("Ammo: ", balas)
	
	espera_disparo = tiempoEntreDis
	if balas <= 0:
		espera_recarga = tiempo_cooldown
 
