extends Control

@onready var current_weapon_label: Label = $Panel/VBox/CurrentWeaponLabel
@onready var next_weapon_label: Label = $Panel/VBox/NextWeaponLabel
@onready var cost_label: Label = $Panel/VBox/CostLabel
@onready var upgrade_button: Button = $Panel/VBox/UpgradeButton
@onready var close_button: Button = $Panel/VBox/CloseButton
@onready var gold_label: Label = $Panel/GoldLabel

const UPGRADE_COSTS := [0, 100, 250, 500, 1000]

func _ready() -> void:
	upgrade_button.pressed.connect(_on_upgrade)
	close_button.pressed.connect(func(): visible = false)
	GameManager.gold_changed.connect(func(_g): refresh())

func refresh() -> void:
	var level := GameManager.weapon_level
	var current := GameManager.get_current_weapon()
	current_weapon_label.text = "현재: " + current.get("name", "?") + "\n공격력: " + str(current.get("attack", 0))
	gold_label.text = "💰 " + str(GameManager.gold)

	if level >= 5:
		next_weapon_label.text = "최대 레벨 달성!"
		cost_label.text = ""
		upgrade_button.disabled = true
		return

	var cost := UPGRADE_COSTS[level]
	var weapons: Array = GameManager.weapons_data
	var next: Dictionary = {}
	for w in weapons:
		if w.level == level + 1:
			next = w
			break

	next_weapon_label.text = "다음: " + next.get("name", "?") + "\n공격력: " + str(next.get("attack", 0))
	cost_label.text = "강화 비용: " + str(cost) + " 💰"
	upgrade_button.disabled = not GameManager.can_upgrade()

func _on_upgrade() -> void:
	if GameManager.upgrade_weapon():
		_play_upgrade_effect()
		refresh()

func _play_upgrade_effect() -> void:
	HapticManager.vibrate(120)
	AudioManager.play_sfx("upgrade")
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
