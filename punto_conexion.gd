extends Area2D

enum Direccion {
	ARRIBA,
	ABAJO,
	IZQUIERDA,
	DERECHA
}

@export var direccion: Direccion
signal jugadorEntro(conexion)
		
func _on_body_entered(body: Node2D) -> void:
	print("algo entro: ", body.name)
	if body.is_in_group("jugador"):
		print("se detecto jugador")
		jugadorEntro.emit.call_deferred(self)
