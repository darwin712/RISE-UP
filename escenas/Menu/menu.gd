extends Control

const ESCENA_JUEGO := "res://escenas/main.tscn"

@onready var boton_jugar: Button = $Contenido/Opciones/Jugar


func _ready() -> void:
	boton_jugar.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _al_jugar() -> void:
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _al_salir() -> void:
	get_tree().quit()
