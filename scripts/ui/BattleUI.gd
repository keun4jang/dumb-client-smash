extends CanvasLayer

@onready var enemy_hp_bar: ProgressBar = $TopBar/EnemyHPBar
@onready var player_hp_bar: ProgressBar = $TopBar/PlayerHPBar
@onready var enemy_name_label: Label = $TopBar/EnemyNameLabel
@onready var gold_label: Label = $TopBar/GoldLabel
@onready var combo_label: Label = $ComboLabel
@onready var judgment_label: Label = $JudgmentLabel
@onready var weapon_level_label: Label = $TopBar/WeaponLevelLabel

const JUDGMENT_COLORS := {
	"perfect": Color(1.0, 0.9, 0.0),
	"good": Color(0.4, 1.0, 0.4),
	"miss": Color(1.0, 0.2, 0.2),
	"early": Color(1.0, 0.6, 0.1),
	"fake_blocked": Color(1.0, 0.2, 0.2),
	"miss_fake": Color(0.8, 0.8, 0.8),
}

const JUDGMENT_TEXTS := {
	"perfect": "PERFECT!",
	"good": "GOOD",
	"miss": "MISS...",
	"early": "EARLY",
	"fake_blocked": "TRICKED!",
	"miss_fake": "IGNORED!",
}

func update_enemy_hp(current: int, max_hp: int) -> void:
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = current

func update_player_hp(current: int, max_hp: int) -> void:
	player_hp_bar.max_value = max_hp
	player_hp_bar.value = current

func set_enemy_name(name: String) -> void:
	enemy_name_label.text = name

func update_gold(amount: int) -> void:
	gold_label.text = "💰 " + str(amount)

func update_combo(combo: int) -> void:
	if combo <= 0:
		combo_label.visible = false
		return
	combo_label.visible = true
	combo_label.text = str(combo) + " combo"

func show_combo_text(text: String) -> void:
	combo_label.text = text
	combo_label.add_theme_font_size_override("font_size", 36)
	var tween := create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)

func break_combo_animation() -> void:
	var tween := create_tween()
	tween.tween_property(combo_label, "rotation", 0.15, 0.05)
	tween.tween_property(combo_label, "rotation", -0.15, 0.05)
	tween.tween_property(combo_label, "rotation", 0.0, 0.05)
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): combo_label.modulate.a = 1.0)

func show_judgment(result: String) -> void:
	judgment_label.text = JUDGMENT_TEXTS.get(result, result.to_upper())
	judgment_label.modulate = JUDGMENT_COLORS.get(result, Color.WHITE)
	judgment_label.visible = true
	judgment_label.scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(judgment_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(judgment_label, "scale", Vector2(1.0, 1.0), 0.05)
	tween.tween_interval(0.6)
	tween.tween_property(judgment_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		judgment_label.visible = false
		judgment_label.modulate.a = 1.0
	)

func update_weapon_level(level: int) -> void:
	weapon_level_label.text = "Lv." + str(level)
