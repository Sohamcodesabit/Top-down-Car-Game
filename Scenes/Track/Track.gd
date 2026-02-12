extends Node


class_name Track 


func _on_track_collison_area_entered(area: Area2D) -> void:
	if area is Car: area.hit_boundary()
 
