extends Node2D


@export var arma: Node2D
@export var requiereEliminarSlimes: bool = false #solo final002
@export var yCaida: float = 238.0 #altura donde cae el arma (plataforma del centro)
@export var camaraSigueJugador: bool = false #solo final003 (es mas ancha que la pantalla)
@export var limiteDerecha: int = 1080 #ancho de la sala cuando la camara sigue al jugador
@export var yVacio: float = 330.0 #si un slime cae mas abajo de esto se elimina (se caian al vacio y nunca morian)

@onready var enemigos: Node2D = get_node_or_null("Enemigos")

var armaLiberada: bool = true
var terminado: bool = false

var camara: Camera2D
var camaraPosicion: Vector2
var camaraLimiteDerecha: int


func _ready() -> void:
	if camaraSigueJugador:
		configurarCamara()

	if requiereEliminarSlimes:
		armaLiberada = false
		arma.remove_from_group("arma_suelo") #no se puede agarrar hasta que caiga


func configurarCamara() -> void:
	var jugador = get_tree().get_first_node_in_group("jugador")
	camara = jugador.get_node("Camera2D")
	camaraPosicion = camara.position
	camaraLimiteDerecha = camara.limit_right
	camara.position = Vector2(0, -23)
	camara.limit_right = limiteDerecha


func _exit_tree() -> void:
	if camara != null and is_instance_valid(camara):
		camara.position = camaraPosicion
		camara.limit_right = camaraLimiteDerecha


func _process(_delta: float) -> void:
	if terminado:
		return

	if not armaLiberada:
		if not quedanSlimes():
			armaLiberada = true
			soltarArma()
		return

	if is_instance_valid(arma) and arma.get_parent() != self:
		terminado = true
		await get_tree().create_timer(0.5).timeout
		get_tree().get_first_node_in_group("main").volverDeSalaEspecial()
func quedanSlimes() -> bool:
	for envoltorio in enemigos.get_children():
		if envoltorio.get_child_count() == 0:
			continue
		var cuerpo = envoltorio.get_child(0)
		if cuerpo.is_queued_for_deletion():
			continue
		if cuerpo.global_position.y > yVacio: #se cayo al vacio
			envoltorio.queue_free()
			continue
		return true
	return false


func soltarArma() -> void:
	var tween = create_tween()
	tween.tween_property(arma, "position:y", yCaida, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	arma.add_to_group("arma_suelo")
