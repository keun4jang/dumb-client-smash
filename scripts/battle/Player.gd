extends Node2D

signal attacked(damage: int, is_critical: bool, hit_pos: Vector2)

@onready var visual: Node2D = $Visual

const CRITICAL_CHANCE := 0.15

func on_tap(position: Vector2) -> void:
	var weapon_data := GameManager.get_current_weapon()
	var base_attack: int = weapon_data.get("attack", 10)
	var damage := base_attack + randi_range(0, int(base_attack * 0.1))
	var is_critical := randf() < CRITICAL_CHANCE
	if is_critical:
		var crit_mult: float = float(weapon_data.get("critical", 20)) / 100.0
		damage = int(damage * (1.0 + crit_mult))
	visual.play_attack(is_critical)
	attacked.emit(damage, is_critical, position)
