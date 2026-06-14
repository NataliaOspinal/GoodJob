extends Control

@onready var label_nombre: Label = $FondoCV/LabelNombre
@onready var bloque_soft: ColorRect = $FondoCV/BloqueSoftSkills
@onready var bloque_tech: ColorRect = $FondoCV/BloqueTechSkills
@onready var btn_toque_cerrar: Button = $BtnToqueCerrar
@onready var audio_cv: AudioStreamPlayer = $AudioCV

func _ready() -> void:
	visible = false
	
	btn_toque_cerrar.pressed.connect(_cerrar_cv)
	
	if GameManager.nombre_jugador != "":
		label_nombre.text = GameManager.nombre_jugador
	else:
		label_nombre.text = "Talento UTP"
		
func _process(_delta: float) -> void:
	bloque_soft.visible = not GameManager.cv_soft_skills_desbloqueado
	bloque_tech.visible = not GameManager.cv_tech_skills_desbloqueado

func mostrar_cv() -> void:
	if audio_cv.stream: audio_cv.play()
	
	position.y = get_viewport_rect().size.y
	visible = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.5)

func _cerrar_cv() -> void:
	if audio_cv.stream: audio_cv.play()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", get_viewport_rect().size.y, 0.4)
	
	tween.tween_callback(hide)
