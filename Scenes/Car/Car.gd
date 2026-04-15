extends Area2D

class_name Car 

enum CarState { DRIVING, BOUNCING, SLIPPING }


@export var car_name: String = "Vader"
@export var car_number: int = 0
@export var max_speed: float = 380.0
@export var friction: float = 300.0
@export var acceleration: float = 150.0
@export var steer_strength: float = 6.0
@export var min_steer_factor: float = 0.5
@export var bounce_time: float = 0.8
@export var bounce_force: float = 30.0
@export var slip_speed_range: Vector2 = Vector2(0.2, 0.5)


@onready var crash_effect: CPUParticles2D = $CrashEffect


var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var _bounce_tween: Tween
var _bounce_target: Vector2 = Vector2.ZERO
var _slip_tween: Tween
var _state: CarState = CarState.DRIVING
var _verifications_count: int = 0
var _verifications_passed: Array[int] = []
var _lap_time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _setup(vc: int) -> void:
	_verifications_count = vc
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_lap_time += delta
	_throttle = Input.get_action_strength("ui_up")
	_steer = Input.get_axis("ui_left" , "ui_right")


func _physics_process(delta: float) -> void:
	if _state != CarState.DRIVING: return
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



#region state

func change_state(new_state: CarState) -> void:
	if new_state == _state: return
	_state = new_state
	
	match new_state:
		CarState.BOUNCING:
			bounce()
		CarState.SLIPPING:
			slip_on_oil()

#endregion

#region Bounce


func bounce_done() -> void:
	_bounce_tween = null
	change_state(CarState.DRIVING)




func bounce() -> void:
	_velocity = 0.0
	
	kill_slip_tween()
	
	if _bounce_tween and _bounce_tween.is_running():
		_bounce_tween.kill()
	
	rotation_degrees = fmod(rotation_degrees, 360.0)
	_bounce_tween = create_tween()
	_bounce_tween.set_parallel()
	_bounce_tween.set_ease(Tween.EASE_IN_OUT)
	_bounce_tween.tween_property(self, "position", _bounce_target, bounce_time)
	_bounce_tween.tween_property(self, "rotation_degrees", rotation_degrees + 720.0, bounce_time)
	_bounce_tween.set_parallel(false)
	_bounce_tween.finished.connect(bounce_done)
	



func hit_boundary(dir_to_path: Vector2) -> void:
	crash_effect.restart()
	_bounce_target = position + (dir_to_path * bounce_force)
	change_state(CarState.BOUNCING)

#endregion

#region slipping


func kill_slip_tween() -> void:
	if _slip_tween and _slip_tween.is_running():
		_slip_tween.kill()


func slip_done() -> void:
	_slip_tween = null
	change_state(CarState.DRIVING)


func slip_on_oil() -> void:
	
	
	kill_slip_tween()
	
	rotation_degrees = fmod(rotation_degrees, 360.0)
	_velocity *= randf_range(slip_speed_range.x, slip_speed_range.y)
	_slip_tween = create_tween()
	_slip_tween.set_parallel()
	_slip_tween.set_ease(Tween.EASE_IN_OUT)
	_slip_tween.tween_property(self, "position", position + _velocity * transform.x, bounce_time)
	_slip_tween.tween_property(self, "rotation_degrees", rotation_degrees + 720.0, bounce_time)
	_slip_tween.set_parallel(false)
	_slip_tween.finished.connect(slip_done)

func hit_oil() -> void:
	if _state == CarState.BOUNCING: return
	change_state(CarState.SLIPPING)

#endregion




func lap_completed() -> void:
	if _verifications_count == _verifications_passed.size():
		var lcd: LapCompleteData = LapCompleteData.new(self, _lap_time)
		print("lap_completed %s" % lcd)
		EventHub.emit_on_lap_completed(lcd)
	_verifications_passed.clear()
	_lap_time = 0.0





func hit_verification(verification_id: int) -> void:
	if verification_id not in _verifications_passed:
		_verifications_passed.append(verification_id)
		pass
