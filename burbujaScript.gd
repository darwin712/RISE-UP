extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var sfx_burbuja: AudioStreamPlayer2D = $sfxBurbuja

func _ready() -> void:
	area_2d.body_entered.connect(agarrar)

func agarrar(body: Node2D) -> void:
	
	if "dobleSalto" in body:
		body.dobleSalto = true
		area_2d.set_deferred("monitoring", false)
		hide()
		sfx_burbuja.play()
		await sfx_burbuja.finished
		queue_free() # Destruye este objeto solo después de modificar al jugador
