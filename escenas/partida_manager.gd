
extends Node

@export var salaInicio: PackedScene
@export var listaSalas: Array[PackedScene]
@export var cantidadSalas: int = 15

@onready var contenedorSala = get_node("../SalaActual")
@onready var jugador = get_node("../Jugador")
@onready var transicion = get_node("../Transicion/Desvanecer")
@onready var sfxActual: AudioStreamPlayer2D = $sfxActual

var salaActual: Node2D
var idSalaActual: int = -1

var mapaSalas: Array[Dictionary] = []
var instanciasSalas: Array[Node2D] = []
var plantillas: Array[Node2D] = []

var estaCambiandoSala: bool = false


func _ready():
	add_to_group("main")
	iniciarRun()


func reproducir(stream: AudioStream) -> void:
	sfxActual.stream = stream
	sfxActual.play()

func generarMapa():
	mapaSalas.clear()
	instanciasSalas.clear()
	plantillas.clear()

	var inicio = salaInicio.instantiate() as Node2D

	mapaSalas.append({
		"escena": salaInicio,
		"conexiones": {}
	})

	plantillas.append(inicio)
	instanciasSalas.append(null)

	var escenasUsadas: Array[PackedScene] = [salaInicio]
	var pendientes: Array[Dictionary] = []

	agregarConexionesPendientes(inicio, 0, pendientes)

	while mapaSalas.size() < cantidadSalas and pendientes.size() > 0:

		var pendiente = pendientes.pop_front()

		var idA = pendiente["sala"]
		var nombreConexion = pendiente["conexion"]

		var salaA = plantillas[idA]
		var conexionA = salaA.get_node("Conexiones/" + nombreConexion)

		var resultado = buscarSalaCompatible(
			conexionA,
			escenasUsadas
		)

		if resultado.is_empty():
			continue

		var idNueva = mapaSalas.size()
		var nuevaSala: Node2D = resultado["plantilla"]
		var nombreConexionNueva = resultado["conexion"]

		mapaSalas.append({
			"escena": resultado["escena"],
			"conexiones": {}
		})

		plantillas.append(nuevaSala)
		instanciasSalas.append(null)

		escenasUsadas.append(resultado["escena"])

		mapaSalas[idA]["conexiones"][nombreConexion] = {
			"sala": idNueva,
			"conexion": nombreConexionNueva
		}

		mapaSalas[idNueva]["conexiones"][nombreConexionNueva] = {
			"sala": idA,
			"conexion": nombreConexion
		}

		agregarConexionesPendientes(
			nuevaSala,
			idNueva,
			pendientes,
			nombreConexionNueva
		)

		print("Habitación generada: ", idNueva)

	for plantilla in plantillas:
		plantilla.free()

	plantillas.clear()

	print("Generación terminada. Total de habitaciones: ", mapaSalas.size())


func agregarConexionesPendientes(
	sala: Node2D,
	idSala: int,
	pendientes: Array[Dictionary],
	conexionExcluida: String = ""
):
	var conexiones = sala.get_node("Conexiones").get_children()

	for conexion in conexiones:
		if conexion.name == conexionExcluida:
			continue
		if conexion.tipo == 1:
			continue

		pendientes.append({
			"sala": idSala,
			"conexion": conexion.name
		})


func buscarSalaCompatible(
	conexionA: Node,
	escenasUsadas: Array[PackedScene]
) -> Dictionary:
	
	if conexionA.tipo == 1:
		return {}
		
	var candidatas: Array[PackedScene] = []

	if conexionA.salaForzada != null:
		candidatas.append(conexionA.salaForzada)
	else:
		candidatas = listaSalas.duplicate()

	candidatas.shuffle()

	for escena in candidatas:

		if escenasUsadas.has(escena):
			continue

		var instancia = escena.instantiate() as Node2D
		var conexiones = instancia.get_node("Conexiones").get_children()

		conexiones.shuffle()

		for conexionB in conexiones:
			if conexionB.tipo == 2:
				continue
			if conexionB.direccion != direccionOpuesta(conexionA.direccion):
				continue

			return {
				"escena": escena,
				"plantilla": instancia,
				"conexion": conexionB.name
			}

		instancia.free()

	return {}


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

func obtenerSala(idSala: int) -> Node2D:

	if instanciasSalas[idSala] == null:

		var escena: PackedScene = mapaSalas[idSala]["escena"]
		var nuevaSala = escena.instantiate() as Node2D

		instanciasSalas[idSala] = nuevaSala

		conectarEntrada(nuevaSala, idSala)

	return instanciasSalas[idSala]


func conectarEntrada(sala: Node2D, idSala: int):

	var conexiones = sala.get_node("Conexiones")

	for conexion in conexiones.get_children():

		conexion.jugadorEntro.connect(alEntrarConexion)

		var conexionesMapa: Dictionary = mapaSalas[idSala]["conexiones"]

		if conexionesMapa.has(conexion.name):

			var destino = conexionesMapa[conexion.name]

			conexion.set_meta("sala_destino", destino["sala"])
			conexion.set_meta("conexion_destino", destino["conexion"])


func alEntrarConexion(conexionActual):

	if estaCambiandoSala:
		return

	if not conexionActual.has_meta("sala_destino"):
		return

	var idDestino = conexionActual.get_meta("sala_destino")
	var conexionDestino = conexionActual.get_meta("conexion_destino")

	cambiarSala(idDestino, conexionDestino)


func cambiarSala(idDestino: int, conexionDestino: String):

	if estaCambiandoSala:
		return

	estaCambiandoSala = true
	jugador.set_physics_process(false)

	var tween = create_tween()
	tween.tween_property(transicion, "modulate:a", 1.0, 0.2)
	await tween.finished

	if salaActual != null:
		contenedorSala.remove_child(salaActual)

	var destino = obtenerSala(idDestino)

	contenedorSala.add_child(destino)

	salaActual = destino
	idSalaActual = idDestino

	var puntoEntrada = destino.get_node(
		"Conexiones/" + conexionDestino + "/Entrada"
	)

	jugador.global_position = puntoEntrada.global_position
	jugador.posCheckpoint = puntoEntrada.global_position
	jugador.velocity = Vector2.ZERO

	tween = create_tween()
	tween.tween_property(transicion, "modulate:a", 0.0, 0.2)
	await tween.finished

	jugador.set_physics_process(true)

	await get_tree().create_timer(0.1).timeout

	estaCambiandoSala = false


# INICIAR O REINICIAR PARTIDA

func iniciarRun():
	for sala in instanciasSalas:

		if sala != null and is_instance_valid(sala):

			if sala.get_parent() != null:
				sala.get_parent().remove_child(sala)

			sala.queue_free()

	salaActual = null
	idSalaActual = -1

	generarMapa()
	var inicio = obtenerSala(0)

	contenedorSala.add_child(inicio)

	salaActual = inicio
	idSalaActual = 0

	var puntoInicio = inicio.get_node("SpawnInicial")

	jugador.global_position = puntoInicio.global_position
	jugador.posCheckpoint = puntoInicio.global_position
	jugador.velocity = Vector2.ZERO
