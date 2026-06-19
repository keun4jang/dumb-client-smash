extends Node

const DB_URL := "https://gaesori-game-default-rtdb.firebaseio.com/scores"

signal scores_loaded(scores: Array)
signal score_posted()

var _http_post: HTTPRequest
var _http_get: HTTPRequest
var _js_callback: JavaScriptObject


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
	if OS.get_name() == "Web":
		_fetch_via_js()
	else:
		_http_get.request(DB_URL + ".json")


func _fetch_via_js() -> void:
	_js_callback = JavaScriptBridge.create_callback(_on_js_fetch_done)
	var js_code := """
		fetch('%s.json')
			.then(function(r){ return r.json(); })
			.then(function(data){ godot_firebase_cb(JSON.stringify(data)); })
			.catch(function(e){ godot_firebase_cb('null'); });
	""" % DB_URL
	JavaScriptBridge.get_interface("window").godot_firebase_cb = _js_callback
	JavaScriptBridge.eval(js_code)


func _on_js_fetch_done(args) -> void:
	var text: String = str(args[0])
	_parse_and_emit(text)


func _on_post_completed(_result, _code, _headers, _body) -> void:
	emit_signal("score_posted")


func _on_get_completed(_result, _code, _headers, body: PackedByteArray) -> void:
	_parse_and_emit(body.get_string_from_utf8())


func _parse_and_emit(text: String) -> void:
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
