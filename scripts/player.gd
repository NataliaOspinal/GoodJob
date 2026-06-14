extends CharacterBody2D

@export var walk_speed: float = 120.0
@export var run_speed: float = 160.0
@export var joystick_threshold: float = 70.0
 
@onready var raycast: RayCast2D = $RayCast2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var joystick_active: bool = false
var joystick_start_pos: Vector2 = Vector2.ZERO
var drag_vector: Vector2 = Vector2.ZERO
var touch_area_y_start: float = 0.0
 
func _ready() -> void:
	touch_area_y_start = get_viewport_rect().size.y * 2.0 / 3.0
	raycast.target_position = Vector2(0, 32)
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = true
	anim.play("Idle")
 
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.y >= touch_area_y_start:
			joystick_active = true
			joystick_start_pos = event.position
		elif not event.pressed and joystick_active:
			joystick_active = false
			drag_vector = Vector2.ZERO
			velocity = Vector2.ZERO
	if event is InputEventScreenDrag and joystick_active:
		drag_vector = event.position - joystick_start_pos
 
func _physics_process(_delta: float) -> void:
	if joystick_active and drag_vector.length() > 15:
		var direction: Vector2 = drag_vector.normalized()
		var distance: float = drag_vector.length()
		var current_speed: float = walk_speed
		if distance >= joystick_threshold:
			current_speed = run_speed
		velocity = direction * current_speed
		_update_raycast_direction(direction)
		_update_animations(direction)
	else:
		velocity = Vector2.ZERO
		anim.play("Idle")
	move_and_slide()
 
func _update_raycast_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		raycast.target_position = Vector2(40 if direction.x > 0 else -40, 0)
	else:
		raycast.target_position = Vector2(0, 40 if direction.y > 0 else -40)
 
func _update_animations(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		anim.play("Left")
		anim.flip_h = (direction.x > 0) 
	else:
		if direction.y < 0:
			anim.play("Up")
		else:
			anim.play("Down")
		anim.flip_h = false
