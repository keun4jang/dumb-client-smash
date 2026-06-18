extends Node2D
class_name Enemy

signal hp_changed(current: int, max_hp: int)
signal defeated()

@onready var body: ColorRect = $Body
@onready var face_label: Label = $FaceLabel
@onready var quote_label: Label = $QuoteLabel

var max_hp: int = 100
var current_hp: int = 100
var enemy_data: Dictionary = {}
var _normal_face: String = "(-_-)"

func setup(data: Dictionary) -> void:
	enemy_data = data
	max_hp = data.get("hp", 100)
	current_hp = max_hp
	_normal_face = data.get("face", "(-_-)")
	face_label.text = _normal_face
	quote_label.text = data.get("quote", "")
	hp_changed.emit(current_hp, max_hp)

func take_damage(amount: int, is_critical: bool) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	_play_hit_reaction(is_critical)
	if current_hp <= 0:
		defeated.emit()

func _play_hit_reaction(is_critical: bool) -> void:
	face_label.text = "(*_*)" if is_critical else "(x_x)"
	_knockback()
	_squash_stretch(is_critical)
	var t := get_tree().create_timer(0.3)
	t.timeout.connect(_restore_face)

func _knockback() -> void:
	var original_x := position.x
	var tween := create_tween()
	tween.tween_property(self, "position:x", original_x + 8.0, 0.04)
	tween.tween_property(self, "position:x", original_x, 0.08)

func _squash_stretch(is_critical: bool) -> void:
	var sx := 1.3 if is_critical else 1.15
	var sy := 0.7 if is_critical else 0.85
	var tween := create_tween()
	tween.tween_property(body, "scale", Vector2(sx, sy), 0.05)
	tween.tween_property(body, "scale", Vector2(1.0, 1.0), 0.1)

func _restore_face() -> void:
	face_label.text = _normal_face

func show_defeat_reaction() -> void:
	face_label.text = "(RIP)"
