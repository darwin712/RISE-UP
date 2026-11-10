@tool
extends Marker2D

const ESCENA_SLIME := preload("res://assets/enemigos/slime/slime.tscn")
const ESCENA_ESQUELETO := preload("res://assets/enemigos/arquero/enemigo.tscn")
const ESCENA_FANTASMA := preload("res://assets/enemigos/fantasma/fantasma.tscn")

@export_category("Generacion aleatoria")
@export_range(0.0, 1.0, 0.05) var probabilidad_aparicion := 1.0
@export var permitir_slime := true
@export var permitir_esqueleto := true
@export var permitir_fantasma := true
@export_category("Frecuencia")
@export_range(0, 10, 1) var peso_slime := 5
@export_range(0, 10, 1) var peso_esqueleto := 4
@export_range(0, 10, 1) var peso_fantasma := 1
@export_range(24.0, 120.0, 4.0) var caida_maxima_slime := 48.0

var enemigo_generado: Node2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	generar_enemigo.call_deferred()


func generar_enemigo() -> void:
	if is_instance_valid(enemigo_generado):
		enemigo_generado.queue_free()
		enemigo_generado = null

	if randf() > probabilidad_aparicion:
		return

	var opciones: Array[PackedScene] = []
	if permitir_slime:
		for indice in range(peso_slime):
			opciones.append(ESCENA_SLIME)
	if permitir_esqueleto:
		for indice in range(peso_esqueleto):
			opciones.append(ESCENA_ESQUELETO)
	if permitir_fantasma:
		for indice in range(peso_fantasma):
			opciones.append(ESCENA_FANTASMA)

	if opciones.is_empty():
		return

	var escena_elegida: PackedScene = opciones.pick_random()
	_instanciar_enemigo(escena_elegida)


func _instanciar_enemigo(escena_elegida: PackedScene) -> void:
	enemigo_generado = escena_elegida.instantiate() as Node2D
	enemigo_generado.name = "EnemigoGenerado"
	enemigo_generado.add_to_group("enemigos_generados")
	add_child(enemigo_generado)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(enemigo_generado):
		return
	var cuerpo_slime := enemigo_generado.get_node_or_null("slime") as CharacterBody2D
	if cuerpo_slime == null:
		return
	if cuerpo_slime.global_position.y > global_position.y + caida_maxima_slime:
		_reemplazar_slime_caido()


func _reemplazar_slime_caido() -> void:
	var slime_caido := enemigo_generado
	enemigo_generado = null
	remove_child(slime_caido)
	slime_caido.queue_free()

	var reemplazos: Array[PackedScene] = []
	if permitir_esqueleto:
		for indice in range(maxi(1, peso_esqueleto)):
			reemplazos.append(ESCENA_ESQUELETO)
	if permitir_fantasma:
		for indice in range(maxi(1, peso_fantasma)):
			reemplazos.append(ESCENA_FANTASMA)
	if reemplazos.is_empty():
		return
	_instanciar_enemigo(reemplazos.pick_random())
