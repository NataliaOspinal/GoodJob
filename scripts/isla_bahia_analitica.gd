extends Node2D

# Arrastra tu escena Folder.tscn aquí en el Inspector
@export var escena_folder: PackedScene 

# Puedes arrastrar un Marker2D aquí para usarlo como centro de la explosión de carpetas
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
			# Solo si era la misión de los folders
			limpiar_folders()
			print("Misión de folders cerrada y mapa limpio.")
			
		_:
			print("El evento '", id, "' finalizó, pero no requiere limpieza en la isla.")

func _esparcir_folders() -> void:
	# El gamemanager debe saber que la meta es 5
	GameManager.meta_items = 5
	GameManager.items_recolectados = 0
	GameManager.errores_recolectados = 0
	GameManager.mision_resuelta = false
	
	# Repetimos este bloque 5 veces
	for i in 5:
		_instanciar_folder("azul")
		_instanciar_folder("rojo")
		_instanciar_folder("amarillo")

func _instanciar_folder(color_elegido: String) -> void:
	var nuevo_folder = escena_folder.instantiate()
	nuevo_folder.color_actual = color_elegido
	var posicion_aleatoria = Vector2(randf_range(-200, 200), randf_range(-200, 200))
	if centro_spawn != null:
		nuevo_folder.global_position = centro_spawn.global_position + posicion_aleatoria
	else:
		nuevo_folder.global_position = posicion_aleatoria
		
	add_child(nuevo_folder)
	
func limpiar_folders() -> void:
	get_tree().call_group("MisionFolders", "queue_free")

# Al cometerse 3 errores
func reiniciar_mision_folders() -> void:
	print("¡Misión fallida! Borrando folders y reintentando...")
	limpiar_folders()
	_esparcir_folders()
