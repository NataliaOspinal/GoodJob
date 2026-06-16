extends Node2D

@export var escena_folder: PackedScene 

@export var centro_spawn: Marker2D 

func ejecutar_evento(id: String) -> void:
	match id:
		"spawn_folders_azules":
			_esparcir_folders()
		_:
			print("El evento '", id, "' no existe en la isla.")

# El NPC llama a esta función cuando el jugador lee el último diálogo de éxito
func finalizar_evento(id: String) -> void:
	match id:
		"spawn_folders_azules":
			#  Limpiamos el mapa y ocultamos la UI
			limpiar_folders()
			
			if GameManager.has_method("desbloquear_habilidad"):
				GameManager.desbloquear_habilidad("PowerBI")
				
			print("Misión de folders cerrada, mapa limpio y habilidad obtenida.")
			
		_:
			print("El evento '", id, "' finalizó, pero no requiere limpieza en la isla.")

func _esparcir_folders() -> void:
	# El gamemanager debe saber que la meta es 5
	GameManager.meta_items = 5
	GameManager.items_recolectados = 0
	GameManager.errores_recolectados = 0
	GameManager.mision_resuelta = false
	
	#  Encendemos el contador en la UI y lo reiniciamos a 0
	get_tree().call_group("Interfaz", "mostrar_contador_folders", true)
	get_tree().call_group("Interfaz", "actualizar_contador_folders", 0, GameManager.meta_items)
	
	#  Hacemos spawn de las carpetas. Se repite este bloque 5 veces
	for i in 5:
		_instanciar_folder("azul")
		_instanciar_folder("rojo")
		_instanciar_folder("amarillo")

func _instanciar_folder(color_elegido: String) -> void:
	var nuevo_folder = escena_folder.instantiate()
	nuevo_folder.color_actual = color_elegido
	nuevo_folder.global_position = _obtener_posicion_libre()
		
	add_child(nuevo_folder)
	
func limpiar_folders() -> void:
	# Apagamos el UI del contador
	get_tree().call_group("Interfaz", "mostrar_contador_folders", false)
	
	# Destruimos todos los folders que hayan quedado en el mapa
	get_tree().call_group("MisionFolders", "queue_free")

# Al cometerse 3 errores
func reiniciar_mision_folders() -> void:
	print("¡Misión fallida! Borrando folders y reintentando...")
	limpiar_folders() 
	_esparcir_folders()
	
func _obtener_posicion_libre() -> Vector2:
	var espacio_fisico = get_world_2d().direct_space_state
	var intentos = 0
	
	while intentos < 50:
		var pos_aleatoria = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		if centro_spawn != null:
			pos_aleatoria += centro_spawn.global_position
			
		var consulta = PhysicsPointQueryParameters2D.new()
		consulta.position = pos_aleatoria
		
		var colisiones = espacio_fisico.intersect_point(consulta)
		
		if colisiones.is_empty():
			return pos_aleatoria 
			
		intentos += 1
		
	print("Advertencia: Se agotaron los intentos. Forzando aparición.")
	if centro_spawn != null:
		return centro_spawn.global_position
	return Vector2.ZERO
