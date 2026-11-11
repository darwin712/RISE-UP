extends Control

const ESCENA_JUEGO := "res://escenas/main.tscn"

@onready var boton_jugar: Button = $Contenido/Opciones/Jugar
@onready var boton_salir: Button = $Contenido/Opciones/Salir
@onready var flash_trueno: ColorRect = $FlashTrueno
@onready var fundido_negro: ColorRect = $FundidoNegro

var transicion_iniciada := false


func _ready() -> void:
	boton_jugar.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _al_jugar() -> void:
	if transicion_iniciada:
		return
	transicion_iniciada = true
	boton_jugar.disabled = true
	boton_salir.disabled = true
	_reproducir_trueno()
	_sacudir_pantalla()

	var destello := create_tween()
	destello.tween_property(flash_trueno, "modulate:a", 1.0, 0.025)
	destello.tween_property(flash_trueno, "modulate:a", 0.08, 0.10)
	destello.tween_interval(0.07)
	destello.tween_property(flash_trueno, "modulate:a", 0.78, 0.025)
	destello.tween_property(flash_trueno, "modulate:a", 0.0, 0.18)

	await get_tree().create_timer(0.48).timeout
	var fundido := create_tween()
	fundido.tween_property(fundido_negro, "modulate:a", 1.0, 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await fundido.finished
	await get_tree().create_timer(0.12).timeout
	get_tree().change_scene_to_file(ESCENA_JUEGO)


func _sacudir_pantalla() -> void:
	var origen := position
	var sacudida := create_tween()
	for desplazamiento in [Vector2(4, -3), Vector2(-4, 2), Vector2(3, 3), Vector2(-3, -2), Vector2(2, -1), Vector2(-1, 1)]:
		sacudida.tween_property(self, "position", origen + desplazamiento, 0.035)
	sacudida.tween_property(self, "position", origen, 0.07)


func _reproducir_trueno() -> void:
	var reproductor := AudioStreamPlayer.new()
	reproductor.name = "TruenoDeInicio"
	reproductor.stream = _crear_sonido_trueno()
	reproductor.volume_db = -1.5
	get_tree().root.add_child(reproductor)
	reproductor.finished.connect(reproductor.queue_free)
	reproductor.play()


func _crear_sonido_trueno() -> AudioStreamWAV:
	var frecuencia := 44100
	var duracion := 2.2
	var cantidad_muestras := int(frecuencia * duracion)
	var datos := PackedByteArray()
	datos.resize(cantidad_muestras * 2)
	var azar := RandomNumberGenerator.new()
	azar.seed = 74821
	var grave := 0.0
	var grave_lento := 0.0

	for indice in range(cantidad_muestras):
		var tiempo := float(indice) / float(frecuencia)
		var ruido := azar.randf_range(-1.0, 1.0)
		grave += (ruido - grave) * 0.035
		grave_lento += (ruido - grave_lento) * 0.006

		var golpe := exp(-tiempo * 22.0)
		var retumbo := exp(-tiempo * 1.55) * (1.0 - exp(-tiempo * 30.0))
		var eco_uno := exp(-(tiempo - 0.20) * 7.0) if tiempo >= 0.20 else 0.0
		var eco_dos := exp(-(tiempo - 0.48) * 5.0) if tiempo >= 0.48 else 0.0
		var vibracion := sin(tiempo * 92.0) * exp(-tiempo * 2.2)
		var mezcla := ruido * golpe * 1.15
		mezcla += grave * retumbo * 3.4
		mezcla += grave_lento * retumbo * 5.2
		mezcla += grave * eco_uno * 1.1
		mezcla += grave_lento * eco_dos * 1.4
		mezcla += vibracion * 0.13
		mezcla = tanh(mezcla * 1.35) * 0.92
		datos.encode_s16(indice * 2, int(mezcla * 32767.0))

	var sonido := AudioStreamWAV.new()
	sonido.format = AudioStreamWAV.FORMAT_16_BITS
	sonido.mix_rate = frecuencia
	sonido.stereo = false
	sonido.data = datos
	return sonido


func _al_salir() -> void:
	get_tree().quit()
