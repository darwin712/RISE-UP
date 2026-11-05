extends Node

@export var sala_inicio: PackedScene

@onready var contenedorSala = $"../SalaActual"
@onready var jugador = $"../Jugador"

var sala_actual: Node2D

func _ready():
	iniciarRun()

func iniciarRun():
	sala_actual = sala_inicio.instantiate()

	contenedorSala.add_child(sala_actual)

	var punto_inicio = sala_actual.get_node("SpawnInicial")

	jugador.global_position = punto_inicio.global_position
