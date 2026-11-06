extends Node

@export var salaInicio: PackedScene
@export var listaSalas: Array[PackedScene]
@onready var contenedorSala = get_node("../SalaActual")
@onready var jugador = get_node("../Jugador")

var salaActual: Node2D
var habitaciones: Array[Node2D] = []
var estaCambiandoSala = false

func _ready():
	iniciarRun()

func conectarEntrada(sala):
	var conexiones = sala.get_node("Conexiones")
	for conexion in conexiones.get_children():
		conexion.jugadorEntro.connect(generarSala)

func generarSala(conexionActual):
	if conexionActual.has_meta("sala_conectada"):
		var destino = conexionActual.get_meta("sala_conectada")
		var conexionDestino = conexionActual.get_meta("conexion_conectada")
		cambiarSala(destino, conexionDestino)
		return
	
	var salasPosibles = buscarSalas(conexionActual.direccion)
	
	if salasPosibles.size() > 0:
		var elegida = salasPosibles.pick_random()
		
		var nuevaSala = elegida.escena.instantiate()
		contenedorSala.add_child(nuevaSala)
		var conexionNueva = nuevaSala.get_node("Conexiones/"+elegida.conexion)
		
		habitaciones.append(nuevaSala)
		conexionActual.set_meta("sala_conectada", nuevaSala)
		conexionActual.set_meta("conexion_conectada", conexionNueva)
		
		conexionNueva.set_meta("sala_conectada", salaActual)
		conexionNueva.set_meta("conexion_conectada", conexionActual)

		conectarEntrada(nuevaSala)
		cambiarSala(nuevaSala, conexionNueva)
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

func cambiarSala(destino, conexionDestino):
	if estaCambiandoSala:
		return
	estaCambiandoSala = true
	
	if salaActual != null:
		contenedorSala.remove_child(salaActual)
		
	if destino.get_parent() == null:
		contenedorSala.add_child(destino)
	
	salaActual = destino
	var puntoEntrada = conexionDestino.get_node("Marker2D")
	jugador.global_position = puntoEntrada.global_position
	jugador.posCheckpoint = puntoEntrada.global_position
	
	await get_tree().create_timer(0.3).timeout
	estaCambiandoSala = false

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
	habitaciones.append(salaActual)
	var puntoInicio = salaActual.get_node("SpawnInicial")
	jugador.global_position = puntoInicio.global_position
	jugador.posCheckpoint = puntoInicio.global_position
	conectarEntrada(salaActual)
