extends Node


class_name Racecontroller


func _enter_tree() -> void:
	EventHub.on_lap_completed.connect(on_lap_completed)


func on_lap_completed(info: LapCompleteData) -> void:
	print("RaceController on_lap_completed:", info)
