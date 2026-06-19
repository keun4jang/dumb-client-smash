extends Control

const _FONT := preload("res://assets/fonts/NotoSansKR-Regular.ttf")

@onready var start_button: Button = $VBox/StartButton
@onready var leaderboard_button: Button = $VBox/LeaderboardButton
@onready var settings_button: Button = $VBox/SettingsButton
@onready var leaderboard_overlay: Control = $LeaderboardOverlay
@onready var score_list: Label = $LeaderboardOverlay/Panel/VBox/ScoreList
@onready var lb_close: Button = $LeaderboardOverlay/Panel/VBox/CloseButton
@onready var settings_screen: Control = $SettingsScreen


func _ready() -> void:
	for node in [$Title, $Subtitle, start_button, leaderboard_button, settings_button,
			$LeaderboardOverlay/Panel/VBox/PanelTitle, score_list, lb_close]:
		node.add_theme_font_override("font", _FONT)
	start_button.pressed.connect(_on_start)
	leaderboard_button.pressed.connect(_on_leaderboard)
	settings_button.pressed.connect(_on_settings)
	lb_close.pressed.connect(func(): leaderboard_overlay.visible = false)


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/dodge/DodgeScene.tscn")


func _on_leaderboard() -> void:
	var scores: Array = SaveManager.load_scores()
	if scores.is_empty():
		score_list.text = "(아직 기록이 없어요)"
	else:
		var txt := ""
		for i in scores.size():
			var e: Dictionary = scores[i]
			txt += "%d위  %s  %d개\n" % [i + 1, e["name"], int(e["score"])]
		score_list.text = txt
	leaderboard_overlay.visible = true


func _on_settings() -> void:
	settings_screen.visible = true
