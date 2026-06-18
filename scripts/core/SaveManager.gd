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

func save_score(player_name: String, score: float) -> void:
	var scores: Array = load_scores()
	scores.append({"name": player_name, "score": score})
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if scores.size() > 10:
		scores.resize(10)
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	for i in scores.size():
		cfg.set_value("scores", "name_%d" % i, scores[i]["name"])
		cfg.set_value("scores", "score_%d" % i, scores[i]["score"])
	cfg.set_value("scores", "count", scores.size())
	cfg.save(SAVE_PATH)


func load_scores() -> Array:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	var count: int = cfg.get_value("scores", "count", 0)
	var result: Array = []
	for i in count:
		result.append({
			"name": cfg.get_value("scores", "name_%d" % i, "?"),
			"score": cfg.get_value("scores", "score_%d" % i, 0.0),
		})
	return result


func load_settings() -> Dictionary:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	return {
		"bgm_volume": cfg.get_value("settings", "bgm_volume", 0.8),
		"sfx_volume": cfg.get_value("settings", "sfx_volume", 1.0),
		"vibration": cfg.get_value("settings", "vibration", true),
	}
