extends Node

@export var sala_inicio: PackedScene
@export var listaSalas: Array[PackedScene]

@onready var contenedorSala = $"../SalaActual"
@onready var jugador = $"../Jugador"

var sala_actual: Node2D

func _ready():
	iniciarRun()

func buscarSalas(direccionSalida):
	var salasCompatibles = []
	
	for sala in listaSalas:
		var instanciaSala = sala.instantiate()
		var conexiones = instanciaSala.get_node("Conexiones")
		
		for conexion in conexiones.get_children():
			if conexion.direccion == direccionOpuesta(direccionSalida):
				salasCompatibles.append(sala)
				break
		instanciaSala.free()
	return salasCompatibles

func direccionOpuesta(direccion):
	match direccion:
		0:
			return 1
		1:
			return 0
		2:
			return 3
		3:
			return 2
	return -1

func iniciarRun():
	sala_actual = sala_inicio.instantiate()

	contenedorSala.add_child(sala_actual)

	var punto_inicio = sala_actual.get_node("SpawnInicial")

	jugador.global_position = punto_inicio.global_position
