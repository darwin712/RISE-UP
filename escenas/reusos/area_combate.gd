extends Area2D

@export var barras: Array[StaticBody2D]
var esperaFinal: float = 0.5
var combateActivo: bool = false
var tiempoSinEnemigos: float = 0.0

func _ready() -> void:
	set_physics_process(false)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jugador"):
		return
	if combateActivo:
		return
	iniciarCombate()

func iniciarCombate() -> void:
	if contarEnemigos() == 0:
		return
		
	combateActivo = true
	tiempoSinEnemigos = 0.0
	for barra in barras:
		barra.cerrar()
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if contarEnemigos() > 0:
		tiempoSinEnemigos = 0.0
		return
		
	tiempoSinEnemigos += delta
	if tiempoSinEnemigos >= esperaFinal:
		terminarCombate()

func contarEnemigos() -> int:
	var total: int = 0
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos") and not cuerpo.is_queued_for_deletion():
			total += 1
	return total

func terminarCombate() -> void:
	set_physics_process(false)
	for barra in barras:
		barra.abrir()
