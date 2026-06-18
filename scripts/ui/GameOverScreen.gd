extends Control

signal submitted(player_name: String)

@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var name_input: LineEdit = $Panel/VBox/NameInput
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var leaderboard_label: Label = $Panel/VBox/LeaderboardLabel


func _ready() -> void:
	submit_button.pressed.connect(_on_submit)


func show_result(elapsed: float) -> void:
	score_label.text = "생존 시간: %.1f초" % elapsed
	_refresh_leaderboard()


func _refresh_leaderboard() -> void:
	var scores: Array = SaveManager.load_scores()
	var txt := "=== 역대 기록 ===\n"
	for i in scores.size():
		var entry: Dictionary = scores[i]
		txt += "%d. %s  %.1f초\n" % [i + 1, entry["name"], entry["score"]]
	leaderboard_label.text = txt


func _on_submit() -> void:
	var pname: String = name_input.text.strip_edges()
	if pname.is_empty():
		pname = "무명"
	emit_signal("submitted", pname)
