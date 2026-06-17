extends Camera2D

var _shake_tween: Tween
var _base_offset := Vector2.ZERO

func shake(intensity: float = 8.0, duration: float = 0.3) -> void:
	if _shake_tween:
		_shake_tween.kill()
	_shake_tween = create_tween()
	var steps := int(duration / 0.03)
	for i in steps:
		var target := Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		_shake_tween.tween_property(self, "offset", _base_offset + target, 0.03)
	_shake_tween.tween_property(self, "offset", _base_offset, 0.05)
