extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var sfx_corazon: AudioStreamPlayer2D = $sfxCorazon

func _ready() -> void:
	area_2d.body_entered.connect(curarse)

func curarse(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		area_2d.set_deferred("monitoring", false)
		hide()
		if body.vida < 3:
			body.vida += 1
			print("Has conseguido una vida!")
			print("Vidas restantes: ", body.vida)
		get_tree().get_first_node_in_group("main").reproducir(sfx_corazon.stream)
		desaparecerDelMapa()

func desaparecerDelMapa() -> void:
	var capa = get_parent()
	if capa is TileMapLayer:
		capa.erase_cell(capa.local_to_map(position))
	else:
		queue_free()
