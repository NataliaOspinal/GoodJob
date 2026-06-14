extends Area2D

@export_file("*.tscn") var ruta_destino: String
@export var punto_aparicion: Marker2D

func _al_entrar_a_la_isla(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Validamos que sí haya una ruta a donde viajar
		if ruta_destino != "":
			
			# Definimos la posición a guardar
			if punto_aparicion != null:
				GameManager.posicion_overworld = punto_aparicion.global_position
			else:
				GameManager.posicion_overworld = body.global_position	
				
			GameManager.regresando_al_overworld = false
			get_tree().call_deferred("change_scene_to_file", ruta_destino)
			
		else:
			print("Error: Ruta vacía")
