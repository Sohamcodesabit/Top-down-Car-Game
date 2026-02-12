extends Area2D

class_name Car 



@export var max_speed: float = 380.0
@export var friction: float = 300.0
@export var acceleration: float = 150.0
@export var steer_strength: float = 6.0
@export var min_steer_factor: float = 0.5
@export var bounce_time: float = 0.8
@export var bounce_force: float = 30.0


var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var _bounce_tween: Tween
var _bounce_target: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_throttle = Input.get_action_strength("ui_up")
	_steer = Input.get_axis("ui_left" , "ui_right")


func _physics_process(delta: float) -> void:
	apply_throttle(delta)
	apply_rotation(delta)
	position += transform.x * _velocity * delta
	


func apply_throttle(delta: float) -> void:
	if _throttle > 0.0:
		_velocity += acceleration * delta
	else:
		_velocity -= friction * delta
		
	_velocity = clampf(_velocity, 0.0, max_speed)
	

func get_steer_factor() -> float:
	return clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	) * steer_strength



func apply_rotation(delta: float) -> void:
	rotate(get_steer_factor() * delta * _steer)
	

func bounce_done() -> void:
	set_physics_process(true)
	_bounce_tween = null




func bounce() -> void:
	set_physics_process(false)
	_velocity = 0.0
	_bounce_target = position + (-transform.x * bounce_force)
	
	if _bounce_tween and _bounce_tween.is_running():
		_bounce_tween.kill()
	
	rotation_degrees = fmod(rotation_degrees, 360.0)
	_bounce_tween = create_tween()
	_bounce_tween.set_parallel()
	_bounce_tween.tween_property(self, "position", _bounce_target, bounce_time)
	_bounce_tween.tween_property(self, "rotation_degrees", rotation_degrees + 540.0, bounce_time)
	_bounce_tween.set_parallel(false)
	_bounce_tween.finished.connect(bounce_done)
	#position += -transform.x * bounce_force
	#await get_tree().create_timer(bounce_time).timeout
	#set_physics_process(true)



func hit_boundary() -> void:
	bounce()
