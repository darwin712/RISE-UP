extends CanvasLayer

@onready var capa: Control = $Capa
@onready var flash: ColorRect = $Capa/Flash
@onready var fragmentos: Control = $Capa/Fragmentos
@onready var boton_reintentar: Button = $Capa/Contenido/Opciones/Reintentar
@onready var boton_menu: Button = $Capa/Contenido/Opciones/MenuPrincipal

var mostrando := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func mostrar() -> void:
	if mostrando:
		return
	mostrando = true
	get_tree().paused = true

	boton_reintentar.disabled = true
	boton_menu.disabled = true
	capa.visible = true
	capa.modulate.a = 0.0
	flash.modulate.a = 1.0
	_crear_fragmentos()

	var entrada := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	entrada.set_parallel(true)
	entrada.tween_property(capa, "modulate:a", 1.0, 0.45)
	entrada.tween_property(flash, "modulate:a", 0.0, 0.30)
	await entrada.finished

	boton_reintentar.disabled = false
	boton_menu.disabled = false
	boton_reintentar.grab_focus()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
