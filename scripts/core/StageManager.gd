extends Node

signal stage_completed(stage_id: int)
signal all_stages_cleared()

var current_stage_index: int = 0

func get_current_stage() -> Dictionary:
	var stages: Array = GameManager.stages_data
	if current_stage_index < stages.size():
		return stages[current_stage_index]
	return {}

func next_stage() -> void:
	var stages: Array = GameManager.stages_data
	stage_completed.emit(current_stage_index)
	current_stage_index += 1
	if current_stage_index >= stages.size():
		all_stages_cleared.emit()

func reset() -> void:
	current_stage_index = 0
