extends StaticBody2D

@onready var animacion = $AnimatedSprite2D
@onready var colision = $CollisionShape2D
@onready var sfxAbrir: AudioStreamPlayer2D = $sfxAbrir
@onready var sfxCerrar: AudioStreamPlayer2D = $sfxCerrar

var estaCerrada = false

func cerrar():
	if estaCerrada:
		return
		
	estaCerrada = true
	colision.set_deferred("disabled", false)
	animacion.play("cerrar")
	get_tree().get_first_node_in_group("main").reproducir(sfxCerrar.stream)

func abrir():
	if not estaCerrada:
		return
		
	estaCerrada = false
	animacion.play("abrir")
	get_tree().get_first_node_in_group("main").reproducir(sfxAbrir.stream)
	await animacion.animation_finished
	colision.set_deferred("disabled", true)
