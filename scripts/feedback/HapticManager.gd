extends Node

var vibration_enabled: bool = true

func _ready() -> void:
	var settings := SaveManager.load_settings()
	vibration_enabled = settings.get("vibration", true)

func vibrate(duration_ms: int) -> void:
	if not vibration_enabled:
		return
	Input.vibrate_handheld(duration_ms)

func vibrate_sequence(durations: Array) -> void:
	if not vibration_enabled:
		return
	_vibrate_next(durations, 0)

func _vibrate_next(durations: Array, index: int) -> void:
	if index >= durations.size():
		return
	vibrate(durations[index])
	var t := get_tree().create_timer(durations[index] / 1000.0 + 0.05)
	t.timeout.connect(_vibrate_next.bind(durations, index + 1))
