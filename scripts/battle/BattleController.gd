extends Node2D

@onready var player: Node2D = $Player
@onready var enemy_container: Node2D = $EnemyContainer
@onready var camera: Camera2D = $Camera2D
@onready var hit_feedback: Node = $HitFeedbackManager
@onready var battle_ui = $BattleUI
@onready var damage_text_scene: PackedScene = preload("res://scenes/battle/DamageText.tscn")
@onready var hit_effect_scene: PackedScene = preload("res://scenes/battle/HitEffect.tscn")

const ENEMY_SCENE := preload("res://scenes/battle/Enemy.tscn")
const BOSS_SCENE := preload("res://scenes/battle/Boss.tscn")
const PLAYER_MENTAL_HP := 100

var _enemies_data: Array = []
var _current_enemy_index: int = 0
var _current_enemy: Node2D = null
var _is_boss_phase: bool = false
var _player_hp: int = PLAYER_MENTAL_HP
var _combo: int = 0
var _combo_timer: float = 0.0
var _total_gold: int = 0
var _holding: bool = false
var _hit_stop_active: bool = false

func _ready() -> void:
	_enemies_data = GameManager.enemies_data
	hit_feedback.camera = camera
	hit_feedback.damage_text_scene = damage_text_scene
	hit_feedback.hit_effect_scene = hit_effect_scene
	# Connect once here — never again per enemy spawn
	player.attacked.connect(_on_player_attacked)
	battle_ui.update_player_hp(_player_hp, PLAYER_MENTAL_HP)
	_spawn_next_enemy()
	var stage := StageManager.get_current_stage()
	AudioManager.play_bgm(stage.get("bgm", "bgm_office"))

func _process(delta: float) -> void:
	if _combo > 0:
		_combo_timer -= delta
		if _combo_timer <= 0:
			_break_combo()

func _input(event: InputEvent) -> void:
	if _hit_stop_active:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_holding = true
			if _is_boss_phase and _current_enemy:
				(_current_enemy as Boss).on_player_block_start()
			else:
				_attack(event.position)
		else:
			_holding = false
			if _is_boss_phase and _current_enemy:
				(_current_enemy as Boss).on_player_block_release()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_holding = true
			if _is_boss_phase and _current_enemy:
				(_current_enemy as Boss).on_player_block_start()
			else:
				_attack(event.position)
		else:
			_holding = false
			if _is_boss_phase and _current_enemy:
				(_current_enemy as Boss).on_player_block_release()

func _attack(pos: Vector2) -> void:
	player.on_tap(pos)

func _on_player_attacked(damage: int, is_critical: bool, hit_pos: Vector2) -> void:
	if not _current_enemy or _hit_stop_active:
		return

	if _is_boss_phase:
		(_current_enemy as Boss).take_damage(damage, is_critical)
	else:
		(_current_enemy as Enemy).take_damage(damage, is_critical)

	hit_feedback.play_hit(hit_pos, is_critical, GameManager.weapon_level)
	hit_feedback.spawn_damage_text(hit_pos, damage, is_critical)
	_apply_hit_stop(is_critical)
	_increment_combo(is_critical)

func _apply_hit_stop(is_critical: bool) -> void:
	_hit_stop_active = true
	Engine.time_scale = 0.0
	var dur := 0.06 if is_critical else 0.03
	# ignore_time_scale=true so this timer fires even while game is paused
	await get_tree().create_timer(dur, true, false, true).timeout
	Engine.time_scale = 1.0
	_hit_stop_active = false

func _increment_combo(_is_critical: bool) -> void:
	_combo += 1
	_combo_timer = 2.5
	battle_ui.update_combo(_combo)
	if _combo == 10:
		battle_ui.show_combo_text("JUSTICE!")
	elif _combo == 20:
		battle_ui.show_combo_text("UNSTOPPABLE!")

func _break_combo() -> void:
	if _combo > 0:
		battle_ui.break_combo_animation()
	_combo = 0
	battle_ui.update_combo(0)

func _on_enemy_hp_changed(current: int, max_hp: int) -> void:
	battle_ui.update_enemy_hp(current, max_hp)

func _on_enemy_defeated() -> void:
	if _current_enemy and _current_enemy.has_method("show_defeat_reaction"):
		_current_enemy.show_defeat_reaction()
	var reward: int = _enemies_data[_current_enemy_index].get("reward", 30) if _current_enemy_index < _enemies_data.size() else 200
	_total_gold += reward
	battle_ui.update_gold(_total_gold)
	await get_tree().create_timer(0.6).timeout
	_current_enemy_index += 1
	if _current_enemy_index >= _enemies_data.size():
		_start_boss_phase()
	else:
		_spawn_next_enemy()

func _on_boss_defeated() -> void:
	_total_gold += 200
	battle_ui.update_gold(_total_gold)
	await get_tree().create_timer(1.0).timeout
	GameManager.add_gold(_total_gold)
	AudioManager.stop_bgm()
	get_tree().change_scene_to_file("res://scenes/ui/ResultScreen.tscn")

func _on_boss_pattern_result(result: String, damage_taken: int) -> void:
	battle_ui.show_judgment(result)
	if damage_taken > 0:
		_player_hp = max(0, _player_hp - damage_taken)
		battle_ui.update_player_hp(_player_hp, PLAYER_MENTAL_HP)
		if _player_hp <= 0:
			_game_over()

func _game_over() -> void:
	AudioManager.stop_bgm()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/ResultScreen.tscn")

func _spawn_next_enemy() -> void:
	if _current_enemy:
		_current_enemy.queue_free()
		_current_enemy = null
	var data: Dictionary = _enemies_data[_current_enemy_index]
	_current_enemy = ENEMY_SCENE.instantiate()
	enemy_container.add_child(_current_enemy)
	_current_enemy.position = Vector2(195, 380)
	(_current_enemy as Enemy).setup(data)
	_current_enemy.hp_changed.connect(_on_enemy_hp_changed)
	_current_enemy.defeated.connect(_on_enemy_defeated)
	battle_ui.set_enemy_name(data.get("name", ""))
	battle_ui.update_enemy_hp(data.get("hp", 100), data.get("hp", 100))

func _start_boss_phase() -> void:
	_is_boss_phase = true
	if _current_enemy:
		_current_enemy.queue_free()
		_current_enemy = null
	_current_enemy = BOSS_SCENE.instantiate()
	enemy_container.add_child(_current_enemy)
	_current_enemy.position = Vector2(195, 360)
	_current_enemy.hp_changed.connect(_on_enemy_hp_changed)
	_current_enemy.defeated.connect(_on_boss_defeated)
	_current_enemy.pattern_result.connect(_on_boss_pattern_result)
	battle_ui.set_enemy_name("THE BOSS")
	battle_ui.update_enemy_hp(500, 500)
	AudioManager.play_bgm("bgm_boss")
