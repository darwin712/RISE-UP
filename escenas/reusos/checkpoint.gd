extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if Time.get_ticks_msec() < body.ignorarConexionesHasta:
			return
		body.posCheckpoint = global_position
		print("Checkpoint alcanzado")
