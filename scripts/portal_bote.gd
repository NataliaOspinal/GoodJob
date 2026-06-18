extends Area2D

@export_file("*.tscn") var ruta_overworld: String

func _al_entrar_al_bote(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if ruta_overworld != "":
			print("¡Regresando al mar!")
			GameManager.regresando_al_overworld = true
			Transicion.cambiar_escena(ruta_overworld)
		else:
			print("Error: Ruta vacía")
