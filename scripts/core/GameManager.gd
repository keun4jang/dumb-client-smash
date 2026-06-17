extends Node

signal gold_changed(new_gold: int)
signal weapon_upgraded(weapon_data: Dictionary)

const UPGRADE_COSTS := [0, 100, 250, 500, 1000]

var gold: int = 0
var weapon_level: int = 1
var current_stage: int = 1

var weapons_data: Array = []
var enemies_data: Array = []
var stages_data: Array = []
var boss_patterns_data: Array = []

func _ready() -> void:
	load_data()
	var save := SaveManager.load_save()
	gold = save.get("gold", 0)
	weapon_level = save.get("weapon_level", 1)
	current_stage = save.get("stage", 1)

func load_data() -> void:
	weapons_data = _load_json("res://data/weapons.json")
	enemies_data = _load_json("res://data/enemies.json")
	stages_data = _load_json("res://data/stages.json")
	boss_patterns_data = _load_json("res://data/boss_patterns.json")

func _load_json(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open: " + path)
		return []
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("JSON parse error: " + path)
		return []
	return json.data

func get_current_weapon() -> Dictionary:
	for w in weapons_data:
		if w.level == weapon_level:
			return w
	return weapons_data[0] if weapons_data.size() > 0 else {}

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)
	_save()

func can_upgrade() -> bool:
	return weapon_level < 5 and gold >= UPGRADE_COSTS[weapon_level]

func upgrade_weapon() -> bool:
	if not can_upgrade():
		return false
	gold -= UPGRADE_COSTS[weapon_level]
	weapon_level += 1
	_save()
	gold_changed.emit(gold)
	weapon_upgraded.emit(get_current_weapon())
	return true

func _save() -> void:
	SaveManager.save(gold, weapon_level, current_stage)
