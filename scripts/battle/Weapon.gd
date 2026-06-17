extends Node2D

@onready var body: ColorRect = $Body
@onready var trail: ColorRect = $Trail

var _swing_tween: Tween
var _weapon_level: int = 1

func _ready() -> void:
	set_weapon_level(GameManager.weapon_level)

func set_weapon_level(level: int) -> void:
	_weapon_level = level
	var data := GameManager.get_current_weapon()
	if data.is_empty():
		return
	var color := Color(data.get("color", "#ffffff"))
	var sc: float = data.get("scale", 1.0)
	body.color = color
	body.size = Vector2(20 * sc, 80 * sc)
	body.position = Vector2(-10 * sc, -80 * sc)
	trail.visible = level >= 3

func play_swing(is_critical: bool) -> void:
	if _swing_tween:
		_swing_tween.kill()
	_swing_tween = create_tween()
	var forward_dist := 60.0 if is_critical else 40.0
	var duration := 0.07 if is_critical else 0.05

	if _weapon_level >= 3:
		_show_trail()

	_swing_tween.tween_property(self, "position:x", forward_dist, duration) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	_swing_tween.tween_property(self, "position:x", 0.0, 0.1) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

func _show_trail() -> void:
	trail.visible = true
	trail.modulate.a = 0.6
	var t := create_tween()
	t.tween_property(trail, "modulate:a", 0.0, 0.15)
