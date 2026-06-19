extends Node

const FONT := preload("res://assets/fonts/NotoSansKR-Regular.ttf")

func _ready() -> void:
	var theme := Theme.new()
	theme.default_font = FONT
	theme.default_font_size = 16
	get_tree().root.theme = theme
