extends Node

const SAVE_PATH := "user://save.cfg"

func save(gold: int, weapon_level: int, stage: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "gold", gold)
	cfg.set_value("player", "weapon_level", weapon_level)
	cfg.set_value("player", "stage", stage)
	cfg.save(SAVE_PATH)

func load_save() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return {"gold": 0, "weapon_level": 1, "stage": 1}
	return {
		"gold": cfg.get_value("player", "gold", 0),
		"weapon_level": cfg.get_value("player", "weapon_level", 1),
		"stage": cfg.get_value("player", "stage", 1),
	}

func save_settings(bgm_vol: float, sfx_vol: float, vibration: bool) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("settings", "bgm_volume", bgm_vol)
	cfg.set_value("settings", "sfx_volume", sfx_vol)
	cfg.set_value("settings", "vibration", vibration)
	cfg.save(SAVE_PATH)

func load_settings() -> Dictionary:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	return {
		"bgm_volume": cfg.get_value("settings", "bgm_volume", 0.8),
		"sfx_volume": cfg.get_value("settings", "sfx_volume", 1.0),
		"vibration": cfg.get_value("settings", "vibration", true),
	}
