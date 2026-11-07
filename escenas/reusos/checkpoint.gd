extends Area2D

@onready var puntoReaparicion = get_node("puntoReaparicion")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if Time.get_ticks_msec() < body.ignorarConexionesHasta:
			return
		body.posCheckpoint = puntoReaparicion.global_position
		print("Checkpoint alcanzado")
