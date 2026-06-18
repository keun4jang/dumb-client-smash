extends Control

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var gold_label: Label = $Panel/VBox/GoldLabel
@onready var next_button: Button = $Panel/VBox/NextButton
@onready var menu_button: Button = $Panel/VBox/MenuButton

func _ready() -> void:
	next_button.pressed.connect(_on_next)
	menu_button.pressed.connect(_on_menu)
	title_label.text = "Stage Clear!"
	gold_label.text = "Gold: " + str(GameManager.gold)

func _on_next() -> void:
	StageManager.reset()
	get_tree().change_scene_to_file("res://scenes/battle/BattleScene.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
