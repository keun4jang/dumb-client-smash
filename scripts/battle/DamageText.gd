extends Label

func setup(damage: int, is_critical: bool) -> void:
	text = str(damage) + ("!!" if is_critical else "")
	modulate = Color(1.0, 0.3, 0.1) if is_critical else Color(1.0, 1.0, 1.0)
	var font_size := 32 if is_critical else 22
	add_theme_font_size_override("font_size", font_size)
	z_index = 10
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 80.0, 0.7)
	tween.tween_property(self, "modulate:a", 0.0, 0.7).set_delay(0.2)
	tween.chain().tween_callback(queue_free)
