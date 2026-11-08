extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var sfxSwitch: AudioStreamPlayer2D = $sfxSwitch

enum TipoAccion {
	ACTIVAR_SWITCH
}

@export var tipoAccion: TipoAccion
@export var objetivos: Array[Node2D]
@export var texturaActiva: Texture2D
@onready var sprite: Sprite2D = $Sprite2D

var estaActivado = false

func _ready():
	area_2d.add_to_group("ojo")

func recibirDisparo():
	if estaActivado:
		return

	estaActivado = true
	sprite.texture = texturaActiva
	get_tree().get_first_node_in_group("main").reproducir(sfxSwitch.stream)

	match tipoAccion:
		TipoAccion.ACTIVAR_SWITCH:
			for objetivo in objetivos:
				objetivo.activar()
