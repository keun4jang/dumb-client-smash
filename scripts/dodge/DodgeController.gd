extends Node2D

const PHRASES := [
	{"text": "5분만에 되죠? ^^", "type": 0},
	{"text": "오늘까지 가능하죠? ^^", "type": 1},
	{"text": "그냥 참고로요... ^^", "type": 0},
	{"text": "딱 한 번만 더 수정해요 ^^", "type": 0},
	{"text": "뉘앙스가 좀 달라요 ^^", "type": 2},
	{"text": "방향을 바꿔봅시다 ^^", "type": 3},
	{"text": "느낌이 좀 달라요. 다시 해요 ^^", "type": 2},
	{"text": "고생 많으셨어요~ (또 수정) ^^", "type": 1},
	{"text": "전략적으로 접근해봐요 ^^", "type": 0},
	{"text": "심플한데 고급스럽게요 ^^", "type": 2},
	{"text": "감성이 중요하죠 ^^", "type": 0},
	{"text": "경쟁사는 이렇게 하던데요 ^^", "type": 1},
	{"text": "내부 검토 중입니다. 기다려요 ^^", "type": 2},
	{"text": "이건 제 직감인데... ^^", "type": 3},
	{"text": "한번 더 보완해봐요 ^^", "type": 0},
	{"text": "처음부터 다시 하는 게 낫겠어요 ^^", "type": 3},
	{"text": "이 방향으로 계속 가면 될까요? ^^", "type": 0},
	{"text": "프리미엄 느낌이 부족해요 ^^", "type": 1},
	{"text": "MZ세대 감성으로 해봐요 ^^", "type": 1},
	{"text": "바이럴될 것 같아요? ^^", "type": 0},
	{"text": "레퍼런스 좀 더 찾아봐요 ^^", "type": 2},
	{"text": "임팩트가 없어요 ^^", "type": 1},
	{"text": "트렌디하게 가야죠 ^^", "type": 0},
	{"text": "이거 ROI가 나올까요? ^^", "type": 2},
	{"text": "피드백은 월요일에 드릴게요 ^^", "type": 3},
	{"text": "어제까지 부탁했는데... ^^", "type": 3},
	{"text": "디테일이 살아야죠 ^^", "type": 0},
	{"text": "글로벌 감각으로 부탁해요 ^^", "type": 2},
	{"text": "이거 좀 더 세련되게 해줘요 ^^", "type": 1},
	{"text": "스토리텔링이 중요해요 ^^", "type": 0},
]

const TYPE_COLOR := [
	Color(0.2, 0.5, 1.0),
	Color(1.0, 0.55, 0.1),
	Color(0.7, 0.2, 1.0),
	Color(0.9, 0.1, 0.05),
]
const TYPE_SPEED  := [160.0, 280.0, 120.0, 340.0]
const TYPE_WIDTH  := [200.0, 175.0, 290.0, 215.0]
const TYPE_HEIGHT := 58.0
const MAX_HP      := 5
const SCREEN_W    := 390.0
const SCREEN_H    := 844.0

var _hp: int = MAX_HP
var _score: int = 0
var _speed_level: int = 0
var _elapsed: float = 0.0
var _alive: bool = true
var _spawn_timer: float = 0.0
var _spawn_interval: float = 1.3
var _phrases: Array = []
const _FONT := preload("res://assets/fonts/NotoSansKR-Regular.ttf")
var _font: Font = null

@onready var player_visual: Node2D = $PlayerVisual
@onready var score_label: Label = $HUD/ScoreLabel
@onready var hp_label: Label = $HUD/HpLabel


func _apply_font(node: Control) -> void:
	node.add_theme_font_override("font", _FONT)


func _ready() -> void:
	_font = _FONT
	for n in [score_label, hp_label, $HUD/HintLabel, $HUD/BackButton]:
		_apply_font(n)
	score_label.add_theme_color_override("font_color", Color(1, 1, 0.3, 1))
	score_label.add_theme_font_size_override("font_size", 22)
	hp_label.add_theme_font_size_override("font_size", 18)
	$HUD/HintLabel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	$HUD/HintLabel.add_theme_font_size_override("font_size", 14)
	$HUD/BackButton.add_theme_font_size_override("font_size", 14)
	score_label.text = "%d개 격파" % _score
	hp_label.text = _hp_hearts()
	$GameOverScreen.visible = false
	$GameOverScreen.submitted.connect(_on_score_submitted)
	$GameOverScreen.retry.connect(func():
		get_tree().change_scene_to_file("res://scenes/dodge/DodgeScene.tscn")
	)
	$HUD/BackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
	)


func _process(delta: float) -> void:
	if not _alive:
		return
	_elapsed += delta
	_update_spawn(delta)
	_update_phrases(delta)


func _hp_hearts() -> String:
	return "HP: " + "v".repeat(_hp) + "-".repeat(MAX_HP - _hp)


func _input(event: InputEvent) -> void:
	if not _alive:
		return
	var tap_pos := Vector2.ZERO
	var is_tap := false
	if event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
		is_tap = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap_pos = event.position
		is_tap = true
	if is_tap:
		_try_smash(tap_pos)


func _try_smash(tap: Vector2) -> void:
	for i in range(_phrases.size() - 1, -1, -1):
		var info: Dictionary = _phrases[i]
		var nd: ColorRect = info["node"]
		var rect := Rect2(nd.position, nd.size)
		# 터치 영역을 넉넉하게 확장
		rect = rect.grow(16.0)
		if rect.has_point(tap):
			_smash_phrase(i, nd)
			return


func _smash_phrase(idx: int, nd: ColorRect) -> void:
	HapticManager.vibrate()
	_score += 1
	score_label.text = "%d개 격파" % _score
	_phrases.remove_at(idx)
	var new_level := _score / 5
	if new_level > _speed_level:
		_speed_level = new_level
		_show_speedup_notice()
	# 빨간 번쩍임 후 제거
	var tween := create_tween()
	nd.color = Color.WHITE
	tween.tween_property(nd, "scale", Vector2(1.3, 1.3), 0.06)
	tween.tween_property(nd, "modulate:a", 0.0, 0.10)
	tween.tween_callback(nd.queue_free)
	# 캐릭터 흔들기
	var ptween := create_tween()
	ptween.tween_property(player_visual, "rotation_degrees", -12.0, 0.07)
	ptween.tween_property(player_visual, "rotation_degrees", 0.0, 0.10)


func _update_spawn(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var scale_down := 1.0 / (1.0 + _elapsed * 0.010)
		_spawn_interval = clamp(1.3 * scale_down, 0.35, 1.3)
		_spawn_timer = _spawn_interval
		_spawn_phrase()
		if _elapsed > 15.0 and randf() < 0.35:
			_spawn_phrase()
		if _elapsed > 35.0 and randf() < 0.30:
			_spawn_phrase()


func _spawn_phrase() -> void:
	var data: Dictionary = PHRASES[randi() % PHRASES.size()]
	var ptype: int = data["type"]
	var w: float = TYPE_WIDTH[ptype]
	var speed_mult := 1.0 + _elapsed * 0.010 + _speed_level * 0.18
	var speed: float = TYPE_SPEED[ptype] * speed_mult
	var x: float = randf_range(w / 2.0 + 4.0, SCREEN_W - w / 2.0 - 4.0)

	var panel := ColorRect.new()
	panel.color = TYPE_COLOR[ptype]
	panel.size = Vector2(w, TYPE_HEIGHT)
	panel.position = Vector2(x - w / 2.0, -TYPE_HEIGHT - 10.0)
	add_child(panel)

	var lbl := Label.new()
	lbl.text = data["text"]
	lbl.autowrap_mode = 3
	lbl.horizontal_alignment = 1
	lbl.vertical_alignment = 1
	lbl.size = Vector2(w - 8.0, TYPE_HEIGHT)
	lbl.position = Vector2(4.0, 0.0)
	lbl.add_theme_font_override("font", _FONT)
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(lbl)

	_phrases.append({"node": panel, "speed": speed, "type": ptype, "w": w})


func _update_phrases(delta: float) -> void:
	var to_remove := []
	for info in _phrases:
		var nd: ColorRect = info["node"]
		nd.position.y += info["speed"] * delta
		if nd.position.y > SCREEN_H - 20.0:
			to_remove.append(info)
			nd.queue_free()
			_take_damage()
			if not _alive:
				return
	for info in to_remove:
		_phrases.erase(info)


func _show_speedup_notice() -> void:
	var lbl := Label.new()
	lbl.text = "!! 빨라진다!! (x%.1f)" % (1.0 + _speed_level * 0.18)
	lbl.horizontal_alignment = 1
	lbl.add_theme_font_override("font", _FONT)
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.0, 1.0))
	lbl.size = Vector2(390, 60)
	lbl.position = Vector2(0, 380)
	add_child(lbl)
	var t := create_tween()
	t.tween_property(lbl, "position:y", 300.0, 0.4)
	t.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	t.tween_callback(lbl.queue_free)


func _take_damage() -> void:
	_hp -= 1
	HapticManager.vibrate()
	hp_label.text = _hp_hearts()
	# 화면 빨간 번쩍임
	$DamageFlash.modulate = Color(1, 0.2, 0.2, 0.5)
	var t := create_tween()
	t.tween_property($DamageFlash, "modulate:a", 0.0, 0.25)
	if _hp <= 0:
		_die()


func _die() -> void:
	_alive = false
	for info in _phrases:
		(info["node"] as Node).queue_free()
	_phrases.clear()
	$Background.visible = false
	$DamageFlash.visible = false
	$DamageFlash.modulate = Color(1, 1, 1, 0)
	$GameOverScreen.visible = true
	$GameOverScreen.show_result_smash(_score, _elapsed)


func _on_score_submitted(player_name: String) -> void:
	SaveManager.save_score(player_name, float(_score))
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
