extends Camera2D

const PANTALLA := Vector2i(480, 270)
const MARGEN := 112
const RESPALDO := Rect2i(0, -10000000, 480, 10000000 + 271)


func ajustar_a_sala(sala: Node2D) -> void:
	var limites: Rect2i = _calcular_limites(sala)
	var sala_controla_horizontal: bool = "camaraSigueJugador" in sala and sala.camaraSigueJugador

	limit_top = limites.position.y
	limit_bottom = limites.end.y
	if not sala_controla_horizontal:
		limit_left = limites.position.x
		limit_right = limites.end.x
		position.x = 0.0

	reset_smoothing()
	force_update_scroll()


func _calcular_limites(sala: Node2D) -> Rect2i:
	var manual := sala.get_node_or_null("LimitesCamara")
	if manual is Control:
		var r: Rect2 = manual.get_global_rect()
		return _asegurar_pantalla(Rect2i(r.position.round(), r.size.round()))

	var bloques := sala.get_node_or_null("Terreno/Bloques") as TileMapLayer
	if bloques == null or bloques.tile_set == null:
		return RESPALDO

	var usado: Rect2i = bloques.get_used_rect()
	if usado.size == Vector2i.ZERO:
		return RESPALDO

	var tam: Vector2 = Vector2(bloques.tile_set.tile_size)
	var esquina_a: Vector2 = bloques.to_global(Vector2(usado.position) * tam)
	var esquina_b: Vector2 = bloques.to_global(Vector2(usado.end) * tam)

	var izquierda: int = 0
	var derecha: int = PANTALLA.x
	var arriba: int = roundi(esquina_a.y)
	var abajo: int = PANTALLA.y + 1

	if esquina_a.x < -MARGEN:
		izquierda = roundi(esquina_a.x)
	if esquina_b.x > PANTALLA.x + MARGEN:
		derecha = roundi(esquina_b.x)
	if esquina_b.y > PANTALLA.y + MARGEN:
		abajo = roundi(esquina_b.y)

	return _asegurar_pantalla(Rect2i(izquierda, arriba, derecha - izquierda, abajo - arriba))

func _asegurar_pantalla(r: Rect2i) -> Rect2i:
	if r.size.x < PANTALLA.x:
		var falta: int = PANTALLA.x - r.size.x
		r.position.x -= falta / 2
		r.size.x = PANTALLA.x
	if r.size.y < PANTALLA.y:
		r.position.y = r.end.y - PANTALLA.y
		r.size.y = PANTALLA.y
	return r
