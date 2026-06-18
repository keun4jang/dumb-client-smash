extends Control

@onready var gold_label: Label = $GoldLabel
@onready var weapon_label: Label = $WeaponLabel
@onready var start_button: Button = $VBox/StartButton
@onready var upgrade_button: Button = $VBox/UpgradeButton
@onready var settings_button: Button = $VBox/SettingsButton

@onready var upgrade_screen: Control = $UpgradeScreen
@onready var settings_screen: Control = $SettingsScreen

func _ready() -> void:
	_refresh_display()
	start_button.pressed.connect(_on_start)
	upgrade_button.pressed.connect(_on_upgrade)
	settings_button.pressed.connect(_on_settings)
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.weapon_upgraded.connect(_on_weapon_upgraded)
	AudioManager.play_bgm("bgm_office")

func _refresh_display() -> void:
	gold_label.text = "Gold: " + str(GameManager.gold)
	var weapon := GameManager.get_current_weapon()
	weapon_label.text = weapon.get("name", "?") + " (Lv." + str(GameManager.weapon_level) + ")"

func _on_gold_changed(new_gold: int) -> void:
	gold_label.text = "Gold: " + str(new_gold)

func _on_weapon_upgraded(weapon_data: Dictionary) -> void:
	weapon_label.text = weapon_data.get("name", "?") + " (Lv." + str(GameManager.weapon_level) + ")"

func _on_start() -> void:
	AudioManager.stop_bgm()
	StageManager.reset()
	get_tree().change_scene_to_file("res://scenes/battle/BattleScene.tscn")

func _on_upgrade() -> void:
	upgrade_screen.visible = true
	upgrade_screen.refresh()

func _on_settings() -> void:
	settings_screen.visible = true
