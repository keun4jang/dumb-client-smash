extends Node

const DB_URL := "https://gaesori-game-default-rtdb.firebaseio.com/scores"

signal scores_loaded(scores: Array)
signal score_posted()

var _http_post: HTTPRequest
var _http_get: HTTPRequest


func _ready() -> void:
	_http_post = HTTPRequest.new()
	add_child(_http_post)
	_http_post.request_completed.connect(_on_post_completed)

	_http_get = HTTPRequest.new()
	add_child(_http_get)
	_http_get.request_completed.connect(_on_get_completed)


func post_score(player_name: String, score: int) -> void:
	var body := JSON.stringify({"name": player_name, "score": score})
	var headers := ["Content-Type: application/json"]
	_http_post.request(DB_URL + ".json", headers, HTTPClient.METHOD_POST, body)


func fetch_top_scores() -> void:
	var url := DB_URL + ".json?orderBy=\"score\"&limitToLast=10"
	_http_get.request(url)


func _on_post_completed(_result, _code, _headers, _body) -> void:
	emit_signal("score_posted")


func _on_get_completed(_result, _code, _headers, body: PackedByteArray) -> void:
	var text := body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		emit_signal("scores_loaded", [])
		return
	var arr: Array = []
	for key in parsed.keys():
		var entry = parsed[key]
		if entry is Dictionary and entry.has("name") and entry.has("score"):
			arr.append({"name": str(entry["name"]), "score": int(entry["score"])})
	arr.sort_custom(func(a, b): return a["score"] > b["score"])
	if arr.size() > 10:
		arr.resize(10)
	emit_signal("scores_loaded", arr)
