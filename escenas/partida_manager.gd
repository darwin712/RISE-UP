extends Node

@export var salaInicio: PackedScene
@export var listaSalas: Array[PackedScene]
@onready var contenedorSala = $"../SalaActual"
@onready var jugador = $"../Jugador"

var salaActual: Node2D

func _ready():
	iniciarRun()

func conectarEntrada(sala):
	var conexiones = sala.get_node("Conexiones")
	for conexion in conexiones.get_children():
		conexion.jugadorEntro.connect(generarSala)

func generarSala(conexionActual):
	print("RunManager recibio una conexion")
	var salasPosibles = buscarSalas(conexionActual.direccion)
	
	if salasPosibles.size() > 0:
		var elegida = salasPosibles.pick_random()
		
		var nuevaSala = elegida.escena.instantiate()
		contenedorSala.add_child(nuevaSala)
		var conexionNueva = nuevaSala.get_node("Conexiones/"+elegida.conexion)
		
		nuevaSala.global_position += (conexionActual.global_position - conexionNueva.global_position)
		conectarEntrada(nuevaSala)
		print("Sala generada")
	else:
		print("No hay salas compatibles")

func buscarSalas(direccionSalida):
	var salasCompatibles = []
	
	for sala in listaSalas:
		var instanciaSala = sala.instantiate()
		var conexiones = instanciaSala.get_node("Conexiones")
		
		for conexion in conexiones.get_children():
			if conexion.direccion == direccionOpuesta(direccionSalida):
				salasCompatibles.append({
					"escena": sala,
					"conexion": conexion.name
				})
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
	salaActual = salaInicio.instantiate()
	contenedorSala.add_child(salaActual)
	var puntoInicio = salaActual.get_node("SpawnInicial")
	jugador.global_position = puntoInicio.global_position
	conectarEntrada(salaActual)
