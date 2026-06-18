extends Node2D

const PHRASES := [
	# type 0 = normal (blue), type 1 = fast (orange), type 2 = wide (purple), type 3 = danger (red)
	{"text": "5분만에 되죠?", "type": 0},
	{"text": "오늘까지 가능하죠?", "type": 1},
	{"text": "그냥 참고로요...", "type": 0},
	{"text": "딱 한 번만 더 수정해요.", "type": 0},
	{"text": "뉘앙스가 좀 달라요.", "type": 2},
	{"text": "방향을 바꿔봅시다.", "type": 3},
	{"text": "느낌이 좀 달라요. 다시 해요.", "type": 2},
	{"text": "고생 많으셨어요~ (또 수정)", "type": 1},
	{"text": "전략적으로 접근해봐요.", "type": 0},
	{"text": "심플한데 고급스럽게요.", "type": 2},
	{"text": "감성이 중요하죠.", "type": 0},
	{"text": "경쟁사는 이렇게 하던데요.", "type": 1},
	{"text": "내부 검토 중입니다. 기다려요.", "type": 2},
	{"text": "이건 제 직감인데...", "type": 3},
	{"text": "한번 더 보완해봐요.", "type": 0},
	{"text": "사실 처음부터 다시 하는 게 낫겠어요.", "type": 3},
	{"text": "이 방향으로 계속 가면 될까요?", "type": 0},
	{"text": "프리미엄 느낌이 부족해요.", "type": 1},
	{"text": "MZ세대 감성으로 해봐요.", "type": 1},
	{"text": "바이럴될 것 같아요?", "type": 0},
	{"text": "레퍼런스 좀 더 찾아봐요.", "type": 2},
	{"text": "임팩트가 없어요.", "type": 1},
	{"text": "트렌디하게 가야죠.", "type": 0},
	{"text": "이거 ROI가 나올까요?", "type": 2},
	{"text": "피드백은 월요일에 드릴게요.", "type": 3},
	{"text": "어제까지 부탁했는데...", "type": 3},
	{"text": "디테일이 살아야죠.", "type": 0},
	{"text": "글로벌 감각으로 부탁해요.", "type": 2},
	{"text": "이거 좀 더 세련되게 해줘요.", "type": 1},
	{"text": "스토리텔링이 중요해요.", "type": 0},
]

const TYPE_COLOR := [
	Color(0.2, 0.5, 1.0),    # 0 normal - blue
	Color(1.0, 0.55, 0.1),   # 1 fast   - orange
	Color(0.7, 0.2, 1.0),    # 2 wide   - purple
	Color(0.9, 0.1, 0.05),   # 3 danger - red
]
const TYPE_SPEED := [280.0, 460.0, 220.0, 560.0]
const TYPE_WIDTH := [180.0, 160.0, 270.0, 200.0]
const TYPE_HEIGHT := 52.0

const SCREEN_W := 390.0
const SCREEN_H := 844.0
const PLAYER_Y := 720.0
const PLAYER_HALF_W := 22.0
const PLAYER_H := 100.0
const PLAYER_SPEED := 520.0

var _player_x: float = SCREEN_W / 2.0
var _target_x: float = SCREEN_W / 2.0
var _elapsed: float = 0.0
var _alive: bool = true
var _spawn_timer: float = 0.0
var _spawn_interval: float = 1.2
var _labels: Array = []

@onready var player_visual: Node2D = $PlayerVisual
@onready var score_label: Label = $HUD/ScoreLabel
@onready var game_over_screen: Control = $GameOverScreen


func _ready() -> void:
	$GameOverScreen.visible = false
	$GameOverScreen.submitted.connect(_on_score_submitted)


func _process(delta: float) -> void:
	if not _alive:
		return
	_elapsed += delta
	_update_player(delta)
	_update_spawn(delta)
	_update_phrases(delta)
	score_label.text = "생존: %.1f초" % _elapsed


func _update_player(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		_target_x -= PLAYER_SPEED * delta
	if Input.is_action_pressed("ui_right"):
		_target_x += PLAYER_SPEED * delta
	_target_x = clamp(_target_x, PLAYER_HALF_W + 10, SCREEN_W - PLAYER_HALF_W - 10)
	_player_x = move_toward(_player_x, _target_x, PLAYER_SPEED * delta)
	player_visual.position.x = _player_x


func _input(event: InputEvent) -> void:
	if not _alive:
		return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_target_x = event.position.x
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_target_x = event.position.x
		elif event is InputEventMouseButton and event.pressed:
			_target_x = event.position.x


func _update_spawn(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var interval_scale := 1.0 / (1.0 + _elapsed * 0.012)
		_spawn_interval = clamp(1.2 * interval_scale, 0.30, 1.2)
		_spawn_timer = _spawn_interval
		_spawn_phrase()
		if _elapsed > 20.0 and randf() < 0.4:
			_spawn_phrase()
		if _elapsed > 45.0 and randf() < 0.35:
			_spawn_phrase()


func _spawn_phrase() -> void:
	var data: Dictionary = PHRASES[randi() % PHRASES.size()]
	var ptype: int = data["type"]
	var w: float = TYPE_WIDTH[ptype]
	var speed_mult := 1.0 + _elapsed * 0.014
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
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(lbl)

	_labels.append({"node": panel, "speed": speed, "type": ptype, "w": w})


func _update_phrases(delta: float) -> void:
	var to_remove := []
	for info in _labels:
		var nd: ColorRect = info["node"]
		nd.position.y += info["speed"] * delta
		if nd.position.y > SCREEN_H + 20.0:
			to_remove.append(info)
			nd.queue_free()
			continue
		if _check_hit(nd, info["w"]):
			_die()
			return
	for info in to_remove:
		_labels.erase(info)


func _check_hit(nd: ColorRect, pw: float) -> bool:
	var px: float = nd.position.x + pw / 2.0
	var py: float = nd.position.y + TYPE_HEIGHT / 2.0
	var dx: float = abs(px - _player_x)
	var dy: float = py - (PLAYER_Y - PLAYER_H / 2.0)
	return dx < (pw / 2.0 + PLAYER_HALF_W - 8.0) and dy > -10.0 and dy < PLAYER_H + 10.0


func _die() -> void:
	_alive = false
	player_visual.visible = false
	for info in _labels:
		(info["node"] as Node).queue_free()
	_labels.clear()
	$Background.visible = false
	$GameOverScreen.visible = true
	$GameOverScreen.show_result(_elapsed)


func _on_score_submitted(player_name: String) -> void:
	SaveManager.save_score(player_name, _elapsed)
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
