extends Button

var animacion: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_entered.connect(_al_entrar)
	mouse_exited.connect(_al_salir)
	focus_entered.connect(_animar.bind(true))
	focus_exited.connect(_animar.bind(false))
	button_down.connect(_animar_presion)
	button_up.connect(_animar.bind(true))
	resized.connect(_centrar_pivote)
	_centrar_pivote.call_deferred()


func _centrar_pivote() -> void:
	pivot_offset = size * 0.5


func _al_entrar() -> void:
	grab_focus()
	_animar(true)


func _al_salir() -> void:
	if not has_focus():
		_animar(false)


func _detener_animacion() -> void:
	if animacion and animacion.is_valid():
		animacion.kill()


func _animar(seleccionado: bool) -> void:
	_detener_animacion()
	animacion = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	animacion.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var escala_objetivo := Vector2(1.065, 1.065) if seleccionado else Vector2.ONE
	var brillo_objetivo := Color(1.16, 1.12, 1.25, 1.0) if seleccionado else Color.WHITE
	animacion.tween_property(self, "scale", escala_objetivo, 0.16)
	animacion.tween_property(self, "modulate", brillo_objetivo, 0.16)


func _animar_presion() -> void:
	_detener_animacion()
	animacion = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	animacion.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animacion.tween_property(self, "scale", Vector2(0.97, 0.97), 0.07)
	animacion.tween_property(self, "modulate", Color(0.78, 0.82, 1.0, 1.0), 0.07)
