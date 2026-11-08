extends CanvasLayer

const CORAZON_LLENO: Texture2D = preload("res://assets/UI/Corazon.png")
const CORAZON_PERDIDO: Texture2D = preload("res://assets/UI/CorazonNegro.png")
const TAMANO_CORAZON := Vector2(14.0, 14.0)

@onready var contenedor: HBoxContainer = $Margen/Corazones


func _ready() -> void:
	call_deferred("_conectar_jugador")


func _conectar_jugador() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		push_warning("El HUD de vidas no encontro un jugador en el grupo 'jugador'.")
		return

	var actualizador := Callable(self, "_actualizar_vidas")
	if jugador.has_signal("vida_cambiada") and not jugador.is_connected("vida_cambiada", actualizador):
		jugador.connect("vida_cambiada", actualizador)

	_actualizar_vidas(int(jugador.get("vida")), int(jugador.get("vida_maxima")))


func _actualizar_vidas(vida_actual: int, vida_maxima: int) -> void:
	var total := maxi(vida_maxima, 0)
	while contenedor.get_child_count() < total:
		contenedor.add_child(_crear_corazon())
	while contenedor.get_child_count() > total:
		var ultimo := contenedor.get_child(contenedor.get_child_count() - 1)
		contenedor.remove_child(ultimo)
		ultimo.queue_free()

	var corazones_llenos := clampi(vida_actual, 0, total)
	for indice in range(total):
		var corazon := contenedor.get_child(indice) as TextureRect
		corazon.texture = CORAZON_LLENO if indice < corazones_llenos else CORAZON_PERDIDO


func _crear_corazon() -> TextureRect:
	var corazon := TextureRect.new()
	corazon.custom_minimum_size = TAMANO_CORAZON
	corazon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	corazon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	corazon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	corazon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return corazon
