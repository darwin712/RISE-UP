extends Node2D

enum Direccion {
	ARRIBA,
	ABAJO,
	IZQUIERDA,
	DERECHA
}

@export var direccion: Direccion
@export var IdConexion: String
