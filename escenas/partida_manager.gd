extends Node

@export var salaInicio: PackedScene
@export var listaSalas: Array[PackedScene]
@onready var contenedorSala = get_node("../SalaActual")
@onready var jugador = get_node("../Jugador")
@onready var transicion = get_node("../Transicion/Desvanecer")

var salaActual: Node2D
var habitaciones: Array[Node2D] = []
var estaCambiandoSala = false
var habitacionesGeneradas: Array[PackedScene] = []

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
		habitacionesGeneradas.append(elegida.escena)
		
		var nuevaSala = elegida.escena.instantiate()
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
		if habitacionesGeneradas.has(sala):
			continue
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
	jugador.set_physics_process(false)
	
	var tween = create_tween()
	tween.tween_property(transicion, "modulate:a", 1.0, 0.2)
	await tween.finished
	
	if salaActual != null:
		contenedorSala.remove_child(salaActual)
		
	if destino.get_parent() == null:
		contenedorSala.add_child(destino)
	
	salaActual = destino
	var puntoEntrada = conexionDestino.get_node("Entrada")
	jugador.global_position = puntoEntrada.global_position
	jugador.posCheckpoint = puntoEntrada.global_position
	jugador.velocity = Vector2.ZERO
	
	tween = create_tween()
	tween.tween_property(transicion, "modulate:a", 0.0, 0.2)
	await tween.finished
	
	jugador.set_physics_process(true)
	await get_tree().create_timer(0.1).timeout
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
	habitacionesGeneradas.clear()
	habitacionesGeneradas.append(salaInicio)
	
	salaActual = salaInicio.instantiate()
	contenedorSala.add_child(salaActual)
	habitaciones.append(salaActual)
	var puntoInicio = salaActual.get_node("SpawnInicial")
	jugador.global_position = puntoInicio.global_position
	jugador.posCheckpoint = puntoInicio.global_position
	conectarEntrada(salaActual)
