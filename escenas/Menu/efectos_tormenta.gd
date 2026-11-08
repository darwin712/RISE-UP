extends Control

@export_range(10, 160, 1) var cantidad_gotas := 72
@export_range(2.0, 30.0, 0.5) var intervalo_minimo := 7.0
@export_range(2.0, 30.0, 0.5) var intervalo_maximo := 14.0

var gotas: Array[Dictionary] = []
var temporizador_relampago := 0.0
var intensidad_relampago := 0.0
var progreso_rayo := 0.0
var rayo_principal := PackedVector2Array()
var ramas_rayo: Array[PackedVector2Array] = []
var animacion_relampago: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_reiniciar_gotas)
	_reiniciar_gotas()
	temporizador_relampago = randf_range(2.5, 5.0)
	queue_redraw()


func _process(delta: float) -> void:
	_actualizar_lluvia(delta)
	temporizador_relampago -= delta
	if temporizador_relampago <= 0.0:
		_iniciar_relampago()
	queue_redraw()


func _reiniciar_gotas() -> void:
	gotas.clear()
	var area := _area_visible()
	for indice in range(cantidad_gotas):
		gotas.append(_crear_gota(
			Vector2(randf_range(0.0, area.x), randf_range(0.0, area.y))
		))


func _crear_gota(posicion: Vector2) -> Dictionary:
	return {
		"posicion": posicion,
		"velocidad": randf_range(105.0, 175.0),
		"segmentos": randi_range(2, 4),
		"alpha": randf_range(0.12, 0.32)
	}


func _actualizar_lluvia(delta: float) -> void:
	var area := _area_visible()
	for indice in range(gotas.size()):
		var gota := gotas[indice]
		var posicion: Vector2 = gota["posicion"]
		posicion += Vector2(-18.0, float(gota["velocidad"])) * delta
		if posicion.y > area.y + 14.0 or posicion.x < -14.0:
			posicion = Vector2(randf_range(0.0, area.x + 24.0), randf_range(-45.0, -5.0))
		gota["posicion"] = posicion
		gotas[indice] = gota


func _iniciar_relampago() -> void:
	temporizador_relampago = randf_range(intervalo_minimo, intervalo_maximo)
	_crear_rayo()
	progreso_rayo = 0.0
	intensidad_relampago = 0.0
	if animacion_relampago and animacion_relampago.is_valid():
		animacion_relampago.kill()
	animacion_relampago = create_tween()
	animacion_relampago.tween_method(_fijar_progreso_rayo, 0.0, 1.0, 0.14)
	animacion_relampago.parallel().tween_method(_fijar_intensidad, 0.0, 0.85, 0.07)
	animacion_relampago.tween_method(_fijar_intensidad, 0.85, 0.10, 0.10)
	animacion_relampago.tween_interval(0.08)
	animacion_relampago.tween_method(_fijar_intensidad, 0.10, 0.58, 0.04)
	animacion_relampago.tween_method(_fijar_intensidad, 0.58, 0.0, 0.36)
	animacion_relampago.tween_callback(_ocultar_rayo)


func _fijar_intensidad(valor: float) -> void:
	intensidad_relampago = valor
	queue_redraw()


func _fijar_progreso_rayo(valor: float) -> void:
	progreso_rayo = valor
	queue_redraw()


func _ocultar_rayo() -> void:
	progreso_rayo = 0.0
	queue_redraw()


func _crear_rayo() -> void:
	rayo_principal.clear()
	ramas_rayo.clear()
	var area := _area_visible()
	var lado_izquierdo := randf() < 0.5
	var x_base := randf_range(area.x * 0.13, area.x * 0.33) if lado_izquierdo else randf_range(area.x * 0.67, area.x * 0.87)
	var altura_final := randf_range(area.y * 0.38, area.y * 0.66)
	var x_actual := roundf(x_base / 3.0) * 3.0
	var y_actual := -3.0
	while y_actual <= altura_final:
		rayo_principal.append(Vector2(x_actual, y_actual))
		y_actual += 3.0
		var giro := randf()
		if giro < 0.25:
			x_actual -= 3.0
		elif giro > 0.75:
			x_actual += 3.0

	_crear_rama(0.42, -1.0 if lado_izquierdo else 1.0)
	_crear_rama(0.68, 1.0 if lado_izquierdo else -1.0)


func _crear_rama(proporcion: float, direccion: float) -> void:
	if rayo_principal.is_empty():
		return
	var indice_inicio := clampi(int(rayo_principal.size() * proporcion), 0, rayo_principal.size() - 1)
	var posicion := rayo_principal[indice_inicio]
	var rama := PackedVector2Array()
	for paso in range(randi_range(4, 7)):
		posicion += Vector2(3.0 * direccion, 3.0)
		if paso % 2 == 1:
			posicion.x += 3.0 * direccion
		rama.append(posicion)
	ramas_rayo.append(rama)


func _draw() -> void:
	var area := _area_visible()
	if intensidad_relampago > 0.0:
		draw_rect(Rect2(Vector2.ZERO, area), Color(0.62, 0.72, 0.88, intensidad_relampago * 0.20))

	for gota in gotas:
		var posicion: Vector2 = gota["posicion"]
		var color_gota := Color(0.64, 0.72, 0.78, float(gota["alpha"]))
		for segmento in range(int(gota["segmentos"])):
			var bloque := posicion + Vector2(float(segmento), float(-segmento * 3))
			bloque = Vector2(roundf(bloque.x / 2.0) * 2.0, roundf(bloque.y / 2.0) * 2.0)
			draw_rect(Rect2(bloque, Vector2(2.0, 2.0)), color_gota)

	if progreso_rayo > 0.0 and not rayo_principal.is_empty():
		var color_rayo := Color(0.80, 0.88, 1.0, maxf(0.28, minf(1.0, intensidad_relampago * 1.45)))
		var bloques_visibles := mini(rayo_principal.size(), ceili(rayo_principal.size() * progreso_rayo))
		for indice in range(bloques_visibles):
			draw_rect(Rect2(rayo_principal[indice], Vector2(3.0, 3.0)), color_rayo)
		if progreso_rayo > 0.45:
			for rama in ramas_rayo:
				var progreso_rama := clampf((progreso_rayo - 0.45) / 0.55, 0.0, 1.0)
				var bloques_rama := mini(rama.size(), ceili(rama.size() * progreso_rama))
				for indice in range(bloques_rama):
					draw_rect(Rect2(rama[indice], Vector2(3.0, 3.0)), color_rayo)


func _area_visible() -> Vector2:
	if size.x > 1.0 and size.y > 1.0:
		return size
	return get_viewport_rect().size
