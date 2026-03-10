extends Node2D

signal bug_detected(type, details)

@export var player: CharacterBody2D
@export var stuck_threshold: float = 2.0 # Seconds before declaring "Stuck"

var last_position: Vector2
var stuck_timer: float = 0.0

var bug_found_this_step: bool = false
var last_bug_type: String = ""

func _process(delta):
	if not player: return
	
	_check_out_of_bounds()
	_check_stuck_state(delta)
	_check_collision_glitches()

# 1. Detect if player fell through the floor or flew away
func _check_out_of_bounds():
	var screen_size = get_viewport_rect().size
	if player.global_position.y > screen_size.y + 500 or player.global_position.y < -500:
		_report_bug("OUT_OF_BOUNDS", player.global_position)

# 2. Detect if the AI is stuck in a wall corner (Common in Pacman/Car)
func _check_stuck_state(delta):
	if player.velocity.length() < 10.0:
		stuck_timer += delta
	else:
		stuck_timer = 0.0
		
	if stuck_timer > stuck_threshold:
		_report_bug("STUCK_DETECTED", player.global_position)

# 3. Detect "Zittering" (Rapidly flickering inside a wall)
func _check_collision_glitches():
	if player.get_slide_collision_count() > 3:
		_report_bug("COLLISION_FLICKER", player.global_position)

func _report_bug(type: String, pos: Vector2):
	# 1. Set the flag so the AI Controller sees it
	bug_found_this_step = true
	last_bug_type = type
	
	# 2. Print to console for your own debugging
	print("CRITICAL BUG FOUND: ", type, " at ", pos)
	
	# 3. Emit the signal in case other parts of your game want to know
	emit_signal("bug_detected", type, pos)

# Call this at the end of every AI step to reset
func reset_bug_status():
	bug_found_this_step = false
	last_bug_type = ""
