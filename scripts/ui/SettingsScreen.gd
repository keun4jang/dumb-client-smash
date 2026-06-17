extends Control

@onready var bgm_slider: HSlider = $Panel/VBox/BGMRow/BGMSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SFXRow/SFXSlider
@onready var vibration_check: CheckButton = $Panel/VBox/VibrationCheck
@onready var back_button: Button = $Panel/VBox/BackButton

func _ready() -> void:
	var settings := SaveManager.load_settings()
	bgm_slider.value = settings.get("bgm_volume", 0.8)
	sfx_slider.value = settings.get("sfx_volume", 1.0)
	vibration_check.button_pressed = settings.get("vibration", true)

	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	vibration_check.toggled.connect(_on_vibration_toggled)
	back_button.pressed.connect(_on_back)

func _on_bgm_changed(value: float) -> void:
	AudioManager.set_bgm_volume(value)
	_save()

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	_save()

func _on_vibration_toggled(pressed: bool) -> void:
	HapticManager.vibration_enabled = pressed
	_save()

func _save() -> void:
	SaveManager.save_settings(bgm_slider.value, sfx_slider.value, vibration_check.button_pressed)

func _on_back() -> void:
	visible = false
