extends Node

@export var camera: Camera2D
@export var damage_text_scene: PackedScene
@export var hit_effect_scene: PackedScene

func play_hit(position: Vector2, is_critical: bool, weapon_level: int) -> void:
	var weapon := GameManager.get_current_weapon()
	var vib_ms: int = weapon.get("vibration_ms", 30)

	if is_critical:
		(camera as CameraShake).shake(14.0, 0.15)
		HapticManager.vibrate(80)
		_spawn_effect(position, weapon_level, true)
	else:
		(camera as CameraShake).shake(6.0, 0.08)
		HapticManager.vibrate(vib_ms)
		_spawn_effect(position, weapon_level, false)

	var sfx_group: String = weapon.get("hit_sfx_group", "light")
	AudioManager.play_hit_sfx(sfx_group)

func spawn_damage_text(position: Vector2, damage: int, is_critical: bool) -> void:
	if not damage_text_scene:
		return
	var dt = damage_text_scene.instantiate()
	get_tree().current_scene.add_child(dt)
	dt.global_position = position
	dt.setup(damage, is_critical)

func _spawn_effect(position: Vector2, weapon_level: int, is_critical: bool) -> void:
	if not hit_effect_scene:
		return
	var effect = hit_effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = position
	var scale_factor := 0.5 + weapon_level * 0.2
	if is_critical:
		scale_factor *= 1.8
	effect.scale = Vector2(scale_factor, scale_factor)
	if weapon_level >= 5 and is_critical:
		effect.modulate = Color(1.0, 0.2, 0.2)
