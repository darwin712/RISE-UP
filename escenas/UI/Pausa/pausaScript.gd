extends Control


func _ready() -> void:
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func pausa():
	get_tree().paused =!get_tree().paused
	visible=get_tree().paused
	

func _input(event):
	if event.is_action_pressed("pausa"):
		pausa()

func _on_btn_continuar_pressed() -> void:
	pausa()

func _on_btn_reiniciar_pressed() -> void:
	pausa()
	get_tree().reload_current_scene()


func _on_btn_salir_pressed() -> void:
	pausa()
	visible = false
	get_tree().change_scene_to_file("res://escenas/Menu/menu.tscn")
