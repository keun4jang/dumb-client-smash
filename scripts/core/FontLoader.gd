extends Node

func _ready() -> void:
	var font := load("res://assets/fonts/NotoSansKR-Regular.ttf")
	if font:
		var theme := Theme.new()
		theme.default_font = font
		theme.default_font_size = 16
		get_tree().root.theme = theme
