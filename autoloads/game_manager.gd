extends Node

var genero_jugador: String = ""
var nombre_jugador: String = ""
var carrera_jugador: String = ""
var especializacion_jugador: String = ""
var cv_soft_skills_desbloqueado: bool = false
var cv_tech_skills_desbloqueado: bool = false
var habilidades_desbloqueadas: Array = []
var npcs_atrapados: int = 0
var meta_npcs: int = 0
var juego_atrapados_activo: bool = false

var posicion_overworld: Vector2 = Vector2.ZERO
var regresando_al_overworld: bool = false

var items_recolectados: int = 0
var meta_items: int = 15
var mision_resuelta: bool = false
var errores_recolectados: int = 0

func registrar_item_recogido() -> void:
	items_recolectados += 1
	get_tree().call_group("Interfaz", "actualizar_contador_folders", items_recolectados, meta_items)
	
	if items_recolectados >= meta_items:
		mision_resuelta = true
		print("¡Misión completada!")
		_terminar_minijuego_folders()
	
func registrar_error_carpeta() -> void:
	errores_recolectados += 1
	print("Carpetas incorrectas: ", errores_recolectados, "/3")
	
	if errores_recolectados >= 3:
		print("¡Minijuego fallido!")
		_terminar_minijuego_folders()
		get_tree().call_deferred("call_group", "GestorEventos", "reiniciar_mision_folders")

func _terminar_minijuego_folders() -> void:
	get_tree().call_group("Interfaz", "mostrar_contador_folders", false)
	get_tree().call_group("FoldersActivos", "queue_free")

func desbloquear_habilidad(nueva_habilidad: String) -> void:
	if nueva_habilidad != "" and not nueva_habilidad in habilidades_desbloqueadas:
		habilidades_desbloqueadas.append(nueva_habilidad)
		print("¡Éxito! Habilidad guardada en la memoria global: ", nueva_habilidad)
		print("Inventario actual: ", habilidades_desbloqueadas)
