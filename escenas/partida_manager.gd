extends Node

@export var salaInicio: PackedScene
@export var listaSalas: Array[PackedScene]
@onready var contenedorSala = get_node("../SalaActual")
@onready var jugador = get_node("../Jugador")
@onready var transicion = get_node("../Transicion/Desvanecer")
@onready var sfxActual: AudioStreamPlayer2D = $sfxActual

var salaActual: Node2D
var habitaciones: Array[Node2D] = []
var estaCambiandoSala = false
var habitacionesGeneradas: Array[PackedScene] = []
var espaciosOcupados: Array[Rect2] = []

func reproducir(stream: AudioStream) -> void:
	sfxActual.stream = stream
	sfxActual.play()

func _ready():
	add_to_group("main")
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
	
	var salasPosibles = buscarSalas(conexionActual)
	
	if salasPosibles.size() > 0:
		var elegida = salasPosibles.pick_random()
		habitacionesGeneradas.append(elegida.escena)
		
		var nuevaSala = elegida.escena.instantiate()
		var conexionNueva = nuevaSala.get_node("Conexiones/"+elegida.conexion)
		nuevaSala.set_meta("pos_mapa", elegida.pos)
		espaciosOcupados.append(espacioEnMapa(nuevaSala))
		
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

func buscarSalas(conexionActual):
	var salasCompatibles = []
	
	for sala in listaSalas:
		if habitacionesGeneradas.has(sala):
			continue
		var instanciaSala = sala.instantiate()
		var conexiones = instanciaSala.get_node("Conexiones")
		
		for conexion in conexiones.get_children():
			if conexion.direccion == direccionOpuesta(conexionActual.direccion):
				var pos = calcularPosicion(conexionActual, instanciaSala, conexion)
				var espacio = espacioLocal(instanciaSala)
				espacio.position += pos
				if cabeEnEspacio(espacio):
					salasCompatibles.append({
						"escena": sala,
						"conexion": conexion.name,
						"pos": pos
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

#todo esto es para que posicione bien las salas y pos tenga sentido
func espacioLocal(sala: Node2D) -> Rect2:
	var terreno = sala.get_node("Terreno")
	var tilemap: TileMapLayer = terreno.get_node("Bloques")
	var usado = tilemap.get_used_rect()
	var tamano = Vector2(tilemap.tile_set.tile_size)
	return Rect2(terreno.position + tilemap.position + Vector2(usado.position) * tamano, Vector2(usado.size) * tamano)

func espacioEnMapa(sala: Node2D) -> Rect2:
	var espacio = espacioLocal(sala)
	espacio.position += sala.get_meta("pos_mapa")
	return espacio

func calcularPosicion(conexionA, salaB, conexionB) -> Vector2:
	var offA: Vector2 = salaActual.get_meta("pos_mapa")
	var rA = espacioLocal(salaActual)
	var rB = espacioLocal(salaB)
	var pos = Vector2.ZERO
	match conexionA.direccion:
		0:
			pos.y = offA.y + rA.position.y - rB.end.y
			pos.x = offA.x + conexionA.position.x - conexionB.position.x
		1:
			pos.y = offA.y + rA.end.y - rB.position.y
			pos.x = offA.x + conexionA.position.x - conexionB.position.x
		2:
			pos.x = offA.x + rA.position.x - rB.end.x
			pos.y = offA.y + conexionA.position.y - conexionB.position.y
		3:
			pos.x = offA.x + rA.end.x - rB.position.x
			pos.y = offA.y + conexionA.position.y - conexionB.position.y
	return pos

func cabeEnEspacio(espacio: Rect2) -> bool:
	for e in espaciosOcupados:
		if e.intersects(espacio):
			return false
	return true

func iniciarRun():
	habitacionesGeneradas.clear()
	habitacionesGeneradas.append(salaInicio)
	espaciosOcupados.clear()
	
	salaActual = salaInicio.instantiate()
	salaActual.set_meta("pos_mapa", Vector2.ZERO)
	espaciosOcupados.append(espacioEnMapa(salaActual))
	
	contenedorSala.add_child(salaActual)
	habitaciones.append(salaActual)
	var puntoInicio = salaActual.get_node("SpawnInicial")
	jugador.global_position = puntoInicio.global_position
	jugador.posCheckpoint = puntoInicio.global_position
	conectarEntrada(salaActual)
