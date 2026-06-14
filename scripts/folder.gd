extends Area2D

@export var img_azul: Texture2D
@export var img_rojo: Texture2D
@export var img_amarillo: Texture2D

var color_actual: String = "azul"

func _ready() -> void:
	add_to_group("MisionFolders")
	
	match color_actual:
		"azul":
			$Sprite2D.texture = img_azul
		"rojo":
			$Sprite2D.texture = img_rojo
		"amarillo":
			$Sprite2D.texture = img_amarillo

	body_entered.connect(_al_ser_tocado)

func _al_ser_tocado(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if color_actual == "azul":
			GameManager.registrar_item_recogido()
			queue_free()
		else:
			GameManager.registrar_error_carpeta()
			queue_free()
