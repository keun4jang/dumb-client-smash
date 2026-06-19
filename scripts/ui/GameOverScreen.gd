extends Control

signal submitted(player_name: String)
signal retry()

@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var name_input: LineEdit = $Panel/VBox/NameInput
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var leaderboard_label: Label = $Panel/VBox/LeaderboardLabel


func _ready() -> void:
	submit_button.pressed.connect(_on_submit)
	retry_button.pressed.connect(func(): emit_signal("retry"))
	var font: Font = load("res://assets/fonts/NotoSansKR-Regular.ttf")
	if font:
		for node in [$Panel/VBox/Title, score_label, leaderboard_label,
				$Panel/VBox/NameHint, name_input, submit_button, retry_button]:
			node.add_theme_font_override("font", font)


func show_result_smash(smashed: int, elapsed: float) -> void:
	score_label.text = "%d개 격파  (%.1f초 생존)" % [smashed, elapsed]
	_refresh_leaderboard()


func _refresh_leaderboard() -> void:
	var scores: Array = SaveManager.load_scores()
	if scores.is_empty():
		leaderboard_label.text = "=== 역대 기록 ===\n(아직 기록 없음)"
		return
	var txt := "=== 역대 기록 ===\n"
	for i in scores.size():
		var entry: Dictionary = scores[i]
		txt += "%d위  %s  %d개\n" % [i + 1, entry["name"], int(entry["score"])]
	leaderboard_label.text = txt


func _on_submit() -> void:
	var pname: String = name_input.text.strip_edges()
	if pname.is_empty():
		pname = "무명"
	emit_signal("submitted", pname)
