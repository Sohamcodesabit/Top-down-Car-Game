extends AIController2D

# 1. Define the character as the parent node
@onready var character = get_parent()
@onready var bug_monitor = $BugMonitor

@export var use_raycasts: bool = true


func _ready():
	super._ready() # Very important! It calls the base library's registration
	# If super._ready() doesn't work, try:
	add_to_group("agent")

# This tells Python: "I have 4 buttons (Left, Right, Up, Down)"
func get_action_space() -> Dictionary:
	return {
		"move_actions" : {
			"size": 4, # 0: Left, 1: Right, 2: Up, 3: Down
			"action_type": "discrete"
		}
	}

func get_obs() -> Dictionary:
	var obs = []
	obs.append(character.global_position.x / 1000.0)
	obs.append(character.global_position.y / 1000.0)
	
	if character.has_node("RayCastContainer"):
		for ray in character.get_node("RayCastContainer").get_children():
			obs.append(ray.get_collision_point().distance_to(character.global_position) / 500.0 if ray.is_colliding() else 1.0)
			
	return {"obs": obs}

func set_action(action):
	var move = action["move_actions"]
	
	# Reset AI inputs
	character.ai_throttle = 0.0
	character.ai_steer = 0.0
	
	# Mapping 0-3 to your Car's movement
	match move:
		0: character.ai_steer = -1.0 # Left
		1: character.ai_steer = 1.0  # Right
		2: character.ai_throttle = 1.0 # Forward
		3: character.ai_throttle = 0.0 # Brake/Coast

func get_reward() -> float:
	var reward = 0.0
	
	if bug_monitor and bug_monitor.bug_found_this_step:
		reward += 100.0 
		bug_monitor.reset_bug_status()
	
	# Reference character's velocity for the exploration bonus
	if character and "velocity" in character:
		reward += character.velocity.length() / 100.0
		
	return reward
func reset():
	character.global_position = Vector2(100, 100) # Reset to start position
	# Or call your game's reset logic:
	# get_parent().reset_game()
