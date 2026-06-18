extends Control

@onready var gold_label: Label = $GoldLabel
@onready var weapon_label: Label = $WeaponLabel
@onready var start_button: Button = $VBox/StartButton
@onready var leaderboard_button: Button = $VBox/LeaderboardButton
@onready var upgrade_button: Button = $VBox/UpgradeButton
@onready var settings_button: Button = $VBox/SettingsButton

@onready var upgrade_screen: Control = $UpgradeScreen
@onready var settings_screen: Control = $SettingsScreen
@onready var leaderboard_overlay: Control = $LeaderboardOverlay
@onready var score_list: Label = $LeaderboardOverlay/Panel/VBox/ScoreList
@onready var lb_close: Button = $LeaderboardOverlay/Panel/VBox/CloseButton


func _ready() -> void:
	_refresh_display()
	start_button.pressed.connect(_on_start)
	leaderboard_button.pressed.connect(_on_leaderboard)
	upgrade_button.pressed.connect(_on_upgrade)
	settings_button.pressed.connect(_on_settings)
	lb_close.pressed.connect(func(): leaderboard_overlay.visible = false)
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.weapon_upgraded.connect(_on_weapon_upgraded)


func _refresh_display() -> void:
	gold_label.text = "Gold: " + str(GameManager.gold)
	var weapon := GameManager.get_current_weapon()
	weapon_label.text = weapon.get("name", "?") + " (Lv." + str(GameManager.weapon_level) + ")"


func _on_gold_changed(new_gold: int) -> void:
	gold_label.text = "Gold: " + str(new_gold)


func _on_weapon_upgraded(weapon_data: Dictionary) -> void:
	weapon_label.text = weapon_data.get("name", "?") + " (Lv." + str(GameManager.weapon_level) + ")"


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
			txt += "%d위  %s  %.1f초\n" % [i + 1, e["name"], e["score"]]
		score_list.text = txt
	leaderboard_overlay.visible = true


func _on_upgrade() -> void:
	upgrade_screen.visible = true
	upgrade_screen.refresh()


func _on_settings() -> void:
	settings_screen.visible = true
