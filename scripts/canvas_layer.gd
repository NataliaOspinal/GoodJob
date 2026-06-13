extends CanvasLayer

@onready var ui_timer: Timer = $UITimer
@onready var margin_container: MarginContainer = $MarginContainer 

var touch_area_y_end: float = 0.0

func _ready() -> void:
	# Área superior es el tercio de arriba de la pantalla (1280 / 3)
	touch_area_y_end = get_viewport().get_visible_rect().size.y / 3.0
	
	# Conectamos el timer con la función _ocultar_ui
	ui_timer.timeout.connect(_ocultar_ui)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# Verificamos si el toque fue en la parte superior de la pantalla
		if event.position.y <= touch_area_y_end:
			_mostrar_ui()

func _mostrar_ui() -> void:
	# Mostramos la interfaz
	margin_container.show()
	# Reiniciamos el temporizador para que cuente los segundos de nuevo
	ui_timer.start() 

func _ocultar_ui() -> void:
	# Ocultamos la interfaz cuando el Timer termina
	margin_container.hide()
