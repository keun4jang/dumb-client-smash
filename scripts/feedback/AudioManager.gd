extends Node

# Dummy audio manager - wire up real AudioStreamPlayer nodes and files here
# File paths under assets/audio/ for easy replacement

const SFX_PATHS := {
	"light":    "res://assets/audio/sfx/hit/hit_light.ogg",
	"medium":   "res://assets/audio/sfx/hit/hit_medium.ogg",
	"heavy":    "res://assets/audio/sfx/hit/hit_heavy.ogg",
	"keyboard": "res://assets/audio/sfx/hit/hit_keyboard.ogg",
	"critical": "res://assets/audio/sfx/hit/hit_critical.ogg",
	"perfect":  "res://assets/audio/sfx/boss/judge_perfect.ogg",
	"good":     "res://assets/audio/sfx/boss/judge_good.ogg",
	"miss":     "res://assets/audio/sfx/boss/judge_miss.ogg",
	"early":    "res://assets/audio/sfx/boss/judge_early.ogg",
	"upgrade":  "res://assets/audio/sfx/ui/upgrade.ogg",
	"button":   "res://assets/audio/sfx/ui/button.ogg",
}

const BGM_PATHS := {
	"bgm_office":  "res://assets/audio/bgm/bgm_office.ogg",
	"bgm_tension": "res://assets/audio/bgm/bgm_tension.ogg",
	"bgm_boss":    "res://assets/audio/bgm/bgm_boss.ogg",
}

var sfx_volume: float = 1.0
var bgm_volume: float = 0.8
var _bgm_player: AudioStreamPlayer

func _ready() -> void:
	var settings := SaveManager.load_settings()
	sfx_volume = settings.get("sfx_volume", 1.0)
	bgm_volume = settings.get("bgm_volume", 0.8)
	_bgm_player = AudioStreamPlayer.new()
	add_child(_bgm_player)

func play_hit_sfx(sfx_group: String) -> void:
	_play_sfx(sfx_group)

func play_sfx(key: String) -> void:
	_play_sfx(key)

func _play_sfx(key: String) -> void:
	if not SFX_PATHS.has(key):
		return
	var path: String = SFX_PATHS[key]
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume)
	player.play()
	player.finished.connect(player.queue_free)

func play_bgm(track: String) -> void:
	if not BGM_PATHS.has(track):
		return
	var path: String = BGM_PATHS[track]
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if not stream:
		return
	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(bgm_volume)
	_bgm_player.play()

func stop_bgm() -> void:
	_bgm_player.stop()

func set_sfx_volume(vol: float) -> void:
	sfx_volume = vol

func set_bgm_volume(vol: float) -> void:
	bgm_volume = vol
	_bgm_player.volume_db = linear_to_db(vol)
