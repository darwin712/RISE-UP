extends Node2D
signal noAmmo
 
@export var escena_bala: PackedScene = preload("res://escenas/reusos/BalaJugador.tscn")
@export var municion: int = 8
@export var tiempoDisparos: float = 1.0  
@export var balaPorDisparo: int = 1          
@export var cooldownDisparos: float = 0.08     
@export var automatica: bool = false           
 
var espera: float = 0.0
var en_rafaga: bool = false
 
func _process(delta: float) -> void:
	if espera > 0.0:
		espera -= delta
 
func disparar(direccion: Vector2) -> void:
	if espera > 0.0 or en_rafaga or municion <= 0:
		return
	en_rafaga = true
	for i in balaPorDisparo:
		if municion <= 0:
			break
		_crear_bala(direccion)
		municion -= 1
		if i < balaPorDisparo - 1:
			await get_tree().create_timer(cooldownDisparos).timeout
			if not is_inside_tree():
				return
	en_rafaga = false
	espera = tiempoDisparos
	if municion <= 0:
		noAmmo.emit()
 
func _crear_bala(direccion: Vector2) -> void:
	var bala = escena_bala.instantiate()
	bala.global_position = global_position
	bala.direccion = direccion
	bala.rotation = direccion.angle()
	get_tree().current_scene.add_child(bala)
