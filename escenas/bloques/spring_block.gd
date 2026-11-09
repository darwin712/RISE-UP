extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfxImpulso: AudioStreamPlayer2D = $sfxImpulso
@export var fuerzaImpulso: float = 485.0

var activo: bool = false

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	animacion.animation_finished.connect(_on_animation_finished)
	animacion.play("off")
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		activo = true
		get_tree().get_first_node_in_group("main").reproducir(sfxImpulso.stream)
		body.impulsar(fuerzaImpulso)
		animacion.play("on")

func _on_animation_finished() -> void:
	if animacion.animation == "on":
		animacion.play("regresar")
	elif animacion.animation == "regresar":
		animacion.play("off")
		activo = false
