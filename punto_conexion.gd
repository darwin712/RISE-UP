extends Area2D
 
enum Direccion {
	ARRIBA,
	ABAJO,
	IZQUIERDA,
	DERECHA
}
 
@export var direccion: Direccion
@export var salaForzada: PackedScene 
var fueUtilizada = false
signal jugadorEntro(conexion)
		
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if Time.get_ticks_msec() < body.ignorarConexionesHasta:
			return
		fueUtilizada = true
		jugadorEntro.emit.call_deferred(self)
 
