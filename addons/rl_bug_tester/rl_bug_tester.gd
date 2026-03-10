@tool
extends EditorPlugin

func _enter_tree():
	# Register the custom nodes without icons for now to stop the errors
	# Ensure these paths match your folder structure exactly!
	add_custom_type(
		"AIController2D", 
		"Node2D", 
		preload("nodes/RL_AI_Controller.gd"), 
		null
	)
	add_custom_type(
		"BugMonitor", 
		"Node2D", 
		preload("nodes/BugMonitor.gd"), 
		null
	)

func _exit_tree():
	# Clean up when the plugin is disabled
	remove_custom_type("AIController2D")
	remove_custom_type("BugMonitor")
