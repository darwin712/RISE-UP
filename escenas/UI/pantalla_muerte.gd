extends CanvasLayer

const ESCENA_MENU := "res://escenas/Menu/menu.tscn"
const CORAZON_VIVO := preload("res://assets/UI/Corazon.png")

@onready var capa: Control = $Capa
@onready var flash: ColorRect = $Capa/Flash
@onready var fragmentos: Control = $Capa/Fragmentos
@onready var brillo_reintento: ColorRect = $Capa/BrilloReintento
@onready var corazon: TextureRect = $Capa/Contenido/Opciones/Corazon
@onready var boton_reintentar: Button = $Capa/Contenido/Opciones/Reintentar
@onready var boton_menu: Button = $Capa/Contenido/Opciones/MenuPrincipal

var mostrando := false


func _ready() -> void:
	capa.visible = false
	call_deferred("_conectar_jugador")


func _conectar_jugador() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		push_warning("La pantalla de muerte no encontro al jugador.")
		return

	var mostrar_pantalla := Callable(self, "mostrar")
	if jugador.has_signal("murio") and not jugador.is_connected("murio", mostrar_pantalla):
		jugador.connect("murio", mostrar_pantalla)


func mostrar() -> void:
	if mostrando:
		return
	mostrando = true
	get_tree().paused = true

	boton_reintentar.disabled = true
	boton_menu.disabled = true
	capa.visible = true
	capa.modulate.a = 0.0
	flash.modulate.a = 1.0
	_crear_fragmentos()

	var entrada := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	entrada.set_parallel(true)
	entrada.tween_property(capa, "modulate:a", 1.0, 0.45)
	entrada.tween_property(flash, "modulate:a", 0.0, 0.30)
	await entrada.finished

	boton_reintentar.disabled = false
	boton_menu.disabled = false
	boton_reintentar.grab_focus()


func _crear_fragmentos() -> void:
	for fragmento in fragmentos.get_children():
		fragmento.queue_free()

	var centro := get_viewport().get_visible_rect().size * 0.5
	for indice in range(18):
		var bloque := ColorRect.new()
		var lado := float(randi_range(2, 4))
		bloque.size = Vector2(lado, lado)
		bloque.position = centro + Vector2(randf_range(-72.0, 72.0), randf_range(-62.0, 12.0))
		bloque.color = Color(0.78, 0.52, 0.60, randf_range(0.35, 0.75)) if indice % 3 == 0 else Color(0.58, 0.62, 0.65, randf_range(0.25, 0.60))
		bloque.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fragmentos.add_child(bloque)

		var destino := bloque.position + Vector2(randf_range(-20.0, 20.0), randf_range(42.0, 105.0))
		var duracion := randf_range(0.9, 1.5)
		var caida := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		caida.set_parallel(true)
		caida.tween_property(bloque, "position", destino, duracion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		caida.tween_property(bloque, "modulate:a", 0.0, duracion)


func _unhandled_input(event: InputEvent) -> void:
	if mostrando and event.is_action_pressed("ui_cancel") and not boton_menu.disabled:
		_al_menu_principal()


func _al_reintentar() -> void:
	if boton_reintentar.disabled:
		return
	boton_reintentar.disabled = true
	boton_menu.disabled = true
	corazon.texture = CORAZON_VIVO
	corazon.pivot_offset = corazon.size * 0.5
	_crear_brillos_corazon()

	var pulso := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pulso.tween_property(corazon, "scale", Vector2(1.38, 1.38), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pulso.parallel().tween_property(corazon, "modulate", Color(1.35, 1.55, 2.0, 1.0), 0.16)
	pulso.parallel().tween_property(brillo_reintento, "modulate:a", 0.26, 0.13)
	pulso.tween_property(corazon, "scale", Vector2(0.94, 0.94), 0.11).set_trans(Tween.TRANS_QUAD)
	pulso.parallel().tween_property(corazon, "modulate", Color.WHITE, 0.11)
	pulso.tween_property(corazon, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pulso.parallel().tween_property(brillo_reintento, "modulate:a", 1.0, 0.18)
	await pulso.finished
	_reiniciar_musica()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _reiniciar_musica() -> void:
	var musica := get_node_or_null("/root/MusicaFondo") as AudioStreamPlayer
	if musica != null:
		musica.stop()
		musica.play(0.0)


func _crear_brillos_corazon() -> void:
	var centro := corazon.get_global_rect().get_center()
	for indice in range(14):
		var brillo := ColorRect.new()
		var lado := float(randi_range(2, 4))
		brillo.size = Vector2(lado, lado)
		brillo.position = centro - brillo.size * 0.5
		brillo.color = Color(0.72, 0.86, 1.0, randf_range(0.65, 1.0)) if indice % 2 == 0 else Color(0.62, 0.52, 1.0, randf_range(0.55, 0.9))
		brillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fragmentos.add_child(brillo)

		var angulo := TAU * float(indice) / 14.0 + randf_range(-0.15, 0.15)
		var destino := brillo.position + Vector2.RIGHT.rotated(angulo) * randf_range(24.0, 48.0)
		var salida := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
		salida.tween_property(brillo, "position", destino, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		salida.tween_property(brillo, "modulate:a", 0.0, 0.42)
		salida.finished.connect(brillo.queue_free)


func _al_menu_principal() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(ESCENA_MENU)
