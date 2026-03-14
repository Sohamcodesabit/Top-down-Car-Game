extends Node


class_name Track 

@onready var track_path: Path2D = $TrackPath
@onready var verification_holder: Node = $VerificationHolder
@onready var cars_holder: Node = $CarsHolder


var _track_curve: Curve2D

func _ready() -> void:
	_track_curve = track_path.curve
	
	for car in cars_holder.get_children():
		if car is Car:
			car._setup(verification_holder.get_children().size())




func get_direction_to_path(from_pos: Vector2) -> Vector2:
	var closest_offset: float = _track_curve.get_closest_offset(from_pos)
	var nearest_point: Vector2 = _track_curve.sample_baked(closest_offset)
	return from_pos.direction_to(nearest_point)


func _on_track_collison_area_entered(area: Area2D) -> void:
	if area is Car: area.hit_boundary(get_direction_to_path(area.position))
 


func _on_start_line_area_entered(area: Area2D) -> void:
	if area is Car: area.lap_completed()
