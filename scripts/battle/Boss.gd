extends Node2D
class_name Boss

signal hp_changed(current: int, max_hp: int)
signal defeated()
signal pattern_started(pattern: Dictionary)
signal pattern_result(result: String, damage_taken: int)

@onready var body: ColorRect = $Body
@onready var face_label: Label = $FaceLabel
@onready var quote_bubble: Panel = $QuoteBubble
@onready var quote_label: Label = $QuoteBubble/QuoteLabel
@onready var charge_bar: ProgressBar = $QuoteBubble/ChargeBar
@onready var pattern_timer: Timer = $PatternTimer

const MAX_HP := 500
const PATTERN_INTERVAL := 4.0

var current_hp: int = MAX_HP
var _patterns: Array = []
var _active_pattern: Dictionary = {}
var _charge_elapsed: float = 0.0
var _is_charging: bool = false
var _player_blocked: bool = false
var _block_time: float = -1.0
var _repeat_count: int = 0

func _ready() -> void:
	_patterns = GameManager.boss_patterns_data
	quote_bubble.visible = false
	pattern_timer.wait_time = PATTERN_INTERVAL
	pattern_timer.timeout.connect(_start_random_pattern)
	pattern_timer.start()
	hp_changed.emit(current_hp, MAX_HP)

func _process(delta: float) -> void:
	if not _is_charging:
		return
	var charge_time: float = _active_pattern.get("charge_time", 2.0)
	_charge_elapsed += delta
	charge_bar.value = _charge_elapsed / charge_time * 100.0

	if _charge_elapsed >= charge_time:
		_is_charging = false  # guard first so _process can't re-enter
		_resolve_pattern()

func take_damage(amount: int, is_critical: bool) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, MAX_HP)
	_play_hit_reaction(is_critical)
	if current_hp <= 0:
		_on_defeated()

func _play_hit_reaction(is_critical: bool) -> void:
	face_label.text = "(*_*)" if is_critical else "(x_x)"
	var tween := create_tween()
	tween.tween_property(body, "scale", Vector2(1.2, 0.85), 0.05)
	tween.tween_property(body, "scale", Vector2(1.0, 1.0), 0.1)
	var t := get_tree().create_timer(0.3)
	t.timeout.connect(func(): face_label.text = ">:(")

func _start_random_pattern() -> void:
	if _patterns.is_empty():
		return
	_active_pattern = _patterns[randi() % _patterns.size()]
	_charge_elapsed = 0.0
	_player_blocked = false
	_block_time = -1.0
	_repeat_count = _active_pattern.get("repeat", 1)
	_is_charging = true
	quote_label.text = _active_pattern.get("quote", "...")
	charge_bar.value = 0
	quote_bubble.visible = true
	pattern_started.emit(_active_pattern)

func on_player_block_start() -> void:
	if not _is_charging:
		return
	_block_time = _charge_elapsed

func on_player_block_release() -> void:
	pass

func _resolve_pattern() -> void:
	_is_charging = false
	quote_bubble.visible = false
	var charge_time: float = _active_pattern.get("charge_time", 2.0)
	var is_fake: bool = _active_pattern.get("is_fake", false)
	var damage: int = _active_pattern.get("damage", 20)
	var perfect_window: float = _active_pattern.get("perfect_window", 0.2)
	var good_window: float = _active_pattern.get("good_window", 0.45)

	var result := "miss"
	var damage_taken := damage

	if _block_time >= 0.0:
		var time_before_end := charge_time - _block_time
		if is_fake:
			result = "fake_blocked"
			damage_taken = int(damage * 0.5) + 5
		elif time_before_end <= perfect_window:
			result = "perfect"
			damage_taken = 0
			take_damage(int(damage * 0.5), false)
		elif time_before_end <= good_window:
			result = "good"
			damage_taken = int(damage * 0.3)
		else:
			result = "early"
			damage_taken = int(damage * 0.5)
	else:
		if is_fake:
			result = "miss_fake"
			damage_taken = 0
		else:
			result = "miss"
			damage_taken = damage

	_play_judgment_feedback(result)
	pattern_result.emit(result, damage_taken)

	_repeat_count -= 1
	if _repeat_count > 0:
		var t := get_tree().create_timer(0.8)
		t.timeout.connect(_start_repeat_pattern)
	else:
		pattern_timer.start()

func _start_repeat_pattern() -> void:
	_charge_elapsed = 0.0
	_player_blocked = false
	_block_time = -1.0  # must reset so previous rep's timing doesn't carry over
	_is_charging = true
	charge_bar.value = 0
	quote_bubble.visible = true

func _play_judgment_feedback(result: String) -> void:
	match result:
		"perfect":
			HapticManager.vibrate(100)
			AudioManager.play_sfx("perfect")
		"good":
			HapticManager.vibrate(60)
			AudioManager.play_sfx("good")
		"miss", "miss_fake":
			HapticManager.vibrate(250)
			AudioManager.play_sfx("miss")
		"early":
			HapticManager.vibrate(150)
			AudioManager.play_sfx("early")
		"fake_blocked":
			HapticManager.vibrate(200)
			AudioManager.play_sfx("miss")

func _on_defeated() -> void:
	pattern_timer.stop()
	_is_charging = false
	quote_bubble.visible = false
	face_label.text = "(RIP)"
	HapticManager.vibrate_sequence([80, 80, 150])
	defeated.emit()
