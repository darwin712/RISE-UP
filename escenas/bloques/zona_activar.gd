extends Area2D

enum TipoAccion {
	ACTIVAR_SWITCH, DESACTIVAR_SWITCH
}

@export var tipoAccion: TipoAccion
@export var objetivos: Array[Node2D]
@export var soloUnaVez: bool = true

var yaActivada: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jugador"):
		return
	if soloUnaVez and yaActivada:
		return
	yaActivada = true

	match tipoAccion:
		TipoAccion.ACTIVAR_SWITCH:
			for objetivo in objetivos:
				objetivo.activar()
		TipoAccion.DESACTIVAR_SWITCH:
			for objetivo in objetivos:
				objetivo.desactivar()
