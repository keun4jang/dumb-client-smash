extends Node2D
class_name Enemy

signal hp_changed(current: int, max_hp: int)
signal defeated()

@onready var visual: Node2D = $Visual
@onready var quote_label: Label = $QuoteLabel

var max_hp: int = 100
var current_hp: int = 100
var enemy_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	enemy_data = data
	max_hp = data.get("hp", 100)
	current_hp = max_hp
	visual.face_state = "normal"
	quote_label.text = data.get("quote", "")
	hp_changed.emit(current_hp, max_hp)

func take_damage(amount: int, is_critical: bool) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	_play_hit_reaction(is_critical)
	if current_hp <= 0:
		defeated.emit()

func _play_hit_reaction(is_critical: bool) -> void:
	visual.face_state = "critical" if is_critical else "hit"
	_knockback()
	_squash_stretch(is_critical)
	var t := get_tree().create_timer(0.35)
	t.timeout.connect(func(): visual.face_state = "normal")

func _knockback() -> void:
	var orig_x := position.x
	var tw := create_tween()
	tw.tween_property(self, "position:x", orig_x + 10.0, 0.04)
	tw.tween_property(self, "position:x", orig_x, 0.09)

func _squash_stretch(is_critical: bool) -> void:
	var sx := 1.35 if is_critical else 1.18
	var sy := 0.68 if is_critical else 0.84
	var tw := create_tween()
	tw.tween_property(visual, "scale", Vector2(sx, sy), 0.05)
	tw.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.12)

func show_defeat_reaction() -> void:
	visual.face_state = "defeat"
