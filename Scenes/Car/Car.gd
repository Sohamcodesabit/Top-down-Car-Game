extends Area2D
class_name Car 

@export var max_speed: float = 380.0
@export var friction: float = 300.0
@export var acceleration: float = 150.0
@export var steer_strength: float = 6.0
@export var min_steer_factor: float = 0.5
@export var bounce_time: float = 0.8
@export var bounce_force: float = 30.0
@onready var crash_effect: CPUParticles2D = $CrashEffect

var _throttle: float = 0.0
var _steer: float = 0.0
var _velocity: float = 0.0
var _bounce_tween: Tween
var _bounce_target: Vector2 = Vector2.ZERO

# --- AI & QA WATCHDOG VARIABLES ---
var is_ai_driving: bool = true # Set to false to drive manually with the keyboard
var ai_steer_input: float = 0.0
var ai_throttle_input: float = 0.0

func _ready() -> void:
	pass

# --- NEW FUNCTION: Receives inputs from car_bug_tester_ai.gd ---
func ai_drive(steer: float, throttle: float) -> void:
	ai_steer_input = steer
	# The AI might send negative throttle, but your game only uses ui_up (0 to 1).
	# We clamp it so the AI only uses forward acceleration, mimicking human input.
	ai_throttle_input = clampf(throttle, 0.0, 1.0) 

func _process(_delta: float) -> void:
	# --- MODIFIED: Switch between AI and Human input ---
	if is_ai_driving:
		_throttle = ai_throttle_input
		_steer = ai_steer_input
	else:
		_throttle = Input.get_action_strength("ui_up")
		_steer = Input.get_axis("ui_left", "ui_right")

func _physics_process(delta: float) -> void:
	apply_throttle(delta)
	apply_rotation(delta)
	position += transform.x * _velocity * delta
	
	# --- NEW: QA BUG TESTING RULES ---
	if is_ai_driving:
		# Rule 1: Check for velocity calculation bugs (clamping failure)
		# We add a tiny 0.1 buffer to account for floating-point rounding errors
		QAManager.assert_rule(
			_velocity <= max_speed + 0.1,
			"Velocity Overflow",
			"Car velocity exceeded the max_speed limit. Clamping failed.",
			{"velocity": _velocity, "position": position}
		)
		
		# Rule 2: Out of bounds detection (Adjust 5000.0 to your actual level size)
		var level_limit = 800
		var in_bounds = position.x > -level_limit and position.x < level_limit and position.y > -level_limit and position.y < level_limit
		QAManager.assert_rule(
			in_bounds,
			"Out of Bounds",
			"Car escaped the playable area.",
			{"position": position, "velocity": _velocity}
		)

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

func bounce(dir_to_path: Vector2) -> void:
	set_physics_process(false)
	_velocity = 0.0
	_bounce_target = position + (dir_to_path * bounce_force)
	
	if _bounce_tween and _bounce_tween.is_running():
		_bounce_tween.kill()
	
	rotation_degrees = fmod(rotation_degrees, 360.0)
	_bounce_tween = create_tween()
	_bounce_tween.set_parallel()
	_bounce_tween.tween_property(self, "position", _bounce_target, bounce_time)
	_bounce_tween.tween_property(self, "rotation_degrees", rotation_degrees + 720.0, bounce_time)
	_bounce_tween.set_parallel(false)
	_bounce_tween.finished.connect(bounce_done)

func hit_boundary(dir_to_path: Vector2) -> void:
	crash_effect.restart()
	bounce(dir_to_path)
