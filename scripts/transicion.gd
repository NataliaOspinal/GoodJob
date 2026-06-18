extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var audio_entrada: AudioStreamPlayer = $AudioEntrada
@onready var audio_salida: AudioStreamPlayer = $AudioSalida

func _ready() -> void:
	color_rect.material.set_shader_parameter("pixelacion", 0.001)
	color_rect.material.set_shader_parameter("oscuridad", 0.0)

func cambiar_escena(ruta_destino: String) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if audio_salida.stream: audio_salida.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(color_rect.material, "shader_parameter/pixelacion", 0.1, 1.0)
	tween.tween_property(color_rect.material, "shader_parameter/oscuridad", 1.0, 1.0)
	
	await tween.finished
	await get_tree().create_timer(0.4).timeout 
	
	get_tree().change_scene_to_file(ruta_destino)
	
	if audio_entrada.stream: audio_entrada.play()
	
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(color_rect.material, "shader_parameter/pixelacion", 0.001, 1.0)
	tween_in.tween_property(color_rect.material, "shader_parameter/oscuridad", 0.0, 1.0)
	
	await tween_in.finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
