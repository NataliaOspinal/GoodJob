extends CanvasLayer

@onready var ui_timer: Timer = $UITimer
@onready var margin_container: MarginContainer = $MarginContainer 

var touch_area_y_end: float = 0.0

func _ready() -> void:
	# Área superior es el tercio de arriba de la pantalla (1280 / 3)
	touch_area_y_end = get_viewport().get_visible_rect().size.y / 3.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if event.position.y <= touch_area_y_end:
			_mostrar_ui()

func _mostrar_ui() -> void:
	ui_timer.start() 
	
	# Si ya está completamente visible, no se hace nada
	if margin_container.visible and margin_container.modulate.a >= 0.95:
		return
		
	# Si está oculta o haciendo el fade-out de bajada, hacemos el fade-in
	margin_container.show()
	var tween = create_tween()
	tween.tween_property(margin_container, "modulate:a", 1.0, 0.3)

func _ocultar_ui() -> void:
	# Tween para el Fade-out
	var tween = create_tween()
	# Transparencia en 0.5 segundos
	tween.tween_property(margin_container, "modulate:a", 0.0, 0.5)
	# Ocultar de verdad
	tween.tween_callback(margin_container.hide)
