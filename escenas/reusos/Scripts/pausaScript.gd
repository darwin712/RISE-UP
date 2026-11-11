extends Control

@onready var boton_continuar: Button = $PanelContainer/VBoxContainer/btnContinuar
@onready var fondo_oscuro: ColorRect = $Oscurecer
@onready var panel_pausa: PanelContainer = $PanelContainer

var bloquear_entrada_hasta := 0


func _ready() -> void:
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel_pausa.resized.connect(_centrar_pivote_panel)
	_centrar_pivote_panel.call_deferred()


func _centrar_pivote_panel() -> void:
	panel_pausa.pivot_offset = panel_pausa.size * 0.5
	
func pausa() -> void:
	if visible:
		cerrar_pausa()
	elif not get_tree().paused:
		abrir_pausa()


func abrir_pausa() -> void:
	get_tree().paused = true
	visible = true
	fondo_oscuro.modulate.a = 0.0
	panel_pausa.modulate.a = 0.0
	panel_pausa.scale = Vector2(0.92, 0.92)
	boton_continuar.grab_focus()
	var entrada := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	entrada.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entrada.tween_property(fondo_oscuro, "modulate:a", 1.0, 0.18)
	entrada.tween_property(panel_pausa, "modulate:a", 1.0, 0.18)
	entrada.tween_property(panel_pausa, "scale", Vector2.ONE, 0.22)


func cerrar_pausa() -> void:
	visible = false
	boton_continuar.release_focus()
	get_tree().paused = false
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa") and Time.get_ticks_msec() >= bloquear_entrada_hasta:
		get_viewport().set_input_as_handled()
		pausa()

func _on_btn_continuar_pressed() -> void:
	bloquear_entrada_hasta = Time.get_ticks_msec() + 180
	cerrar_pausa()

func _on_btn_reiniciar_pressed() -> void:
	var musica := get_node_or_null("/root/MusicaFondo") as AudioStreamPlayer
	if musica != null:
		musica.stop()
		musica.play(0.0)
	bloquear_entrada_hasta = Time.get_ticks_msec() + 180
	visible = false
	boton_continuar.release_focus()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_btn_salir_pressed() -> void:
	bloquear_entrada_hasta = Time.get_ticks_msec() + 180
	get_tree().paused = false
	visible = false
	boton_continuar.release_focus()
	get_tree().change_scene_to_file("res://escenas/Menu/menu.tscn")
