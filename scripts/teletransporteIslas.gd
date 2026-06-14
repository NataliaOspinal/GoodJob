extends Area2D

@export var escena_destino: PackedScene

func _al_entrar_a_la_isla(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if escena_destino != null:
			print("¡Viajando a la isla!")
			get_tree().call_deferred("change_scene_to_packed", escena_destino)
			
		else:
			print("Error: No has asignado una escena de destino en el Inspector")
