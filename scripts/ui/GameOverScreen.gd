extends Control

signal submitted(player_name: String)
signal retry()

@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var name_input: LineEdit = $Panel/VBox/NameInput
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var leaderboard_label: Label = $Panel/VBox/LeaderboardLabel

const _FONT := preload("res://assets/fonts/NotoSansKR-Regular.ttf")

var _last_score: int = 0
var _last_name: String = ""


func _make_ls(size: int, color: Color = Color(0.9, 0.9, 0.9, 1)) -> LabelSettings:
	var s := LabelSettings.new()
	s.font = _FONT
	s.font_size = size
	s.font_color = color
	return s


func _ready() -> void:
	submit_button.pressed.connect(_on_submit)
	retry_button.pressed.connect(func(): emit_signal("retry"))
	$Panel/VBox/Title.label_settings = _make_ls(28, Color(0.9, 0.1, 0.1, 1))
	score_label.label_settings = _make_ls(20)
	leaderboard_label.label_settings = _make_ls(15)
	$Panel/VBox/NameHint.label_settings = _make_ls(14)
	for node in [name_input, submit_button, retry_button]:
		node.add_theme_font_override("font", _FONT)
	OnlineLeaderboard.scores_loaded.connect(_on_scores_loaded)


func show_result_smash(smashed: int, elapsed: float) -> void:
	_last_score = smashed
	score_label.text = "%d개 격파  (%.1f초 생존)" % [smashed, elapsed]
	leaderboard_label.text = "=== 친구들 기록 ===\n불러오는 중..."
	OnlineLeaderboard.fetch_top_scores()


func _on_scores_loaded(scores: Array) -> void:
	if scores.is_empty():
		leaderboard_label.text = "=== 친구들 기록 ===\n(아직 기록 없음)"
		return
	var txt := "=== 친구들 기록 ===\n"
	for i in scores.size():
		var entry: Dictionary = scores[i]
		txt += "%d위  %s  %d개\n" % [i + 1, entry["name"], int(entry["score"])]
	leaderboard_label.text = txt


func _on_submit() -> void:
	var pname: String = name_input.text.strip_edges()
	if pname.is_empty():
		pname = "무명"
	_last_name = pname
	SaveManager.save_score(pname, float(_last_score))
	submit_button.disabled = true
	submit_button.text = "등록 중..."
	OnlineLeaderboard.score_posted.connect(_on_posted, CONNECT_ONE_SHOT)
	OnlineLeaderboard.post_score(pname, _last_score)


func _on_posted() -> void:
	emit_signal("submitted", _last_name)
