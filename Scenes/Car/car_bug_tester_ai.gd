extends AIController2D

@onready var car = $".." # Assumes AIController2D is a direct child of the Car node

# 1. WHAT THE AI SEES (Observations)
func get_obs() -> Dictionary:
	# Your _velocity is a float, so we just divide it by max_speed to keep it between 0.0 and 1.0
	var normalized_speed = car._velocity / car.max_speed
	
	# We pass a single number into the observation array
	return {"obs": [normalized_speed]}

# 2. WHAT THE AI CAN DO (Action Space)
func get_action_space() -> Dictionary:
	return {
		"steer": {"size": 1, "action_type": "continuous"}, 
		"accelerate": {"size": 1, "action_type": "continuous"} 
	}

# 3. HOW THE AI CONTROLS THE GAME (Setting Actions)
func set_action(action) -> void:
	# Log action to the QA Watchdog
	QAManager.log_action(action)
	
	var steering_input = action["steer"][0] 
	var throttle_input = action["accelerate"][0]
	
	car.ai_drive(steering_input, throttle_input)

# 4. WHAT THE AI IS TRYING TO ACHIEVE (Reward Function)
func get_reward() -> float:
	# Reward the AI based on your custom _velocity float
	var reward_amount = car._velocity / 100.0
	return reward_amount
