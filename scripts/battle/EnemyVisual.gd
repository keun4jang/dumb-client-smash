extends Node2D

const C_SKIN    := Color(1.00, 0.83, 0.62)
const C_HAIR    := Color(0.22, 0.16, 0.08)
const C_SUIT    := Color(0.18, 0.18, 0.28)
const C_SHIRT   := Color(0.92, 0.92, 0.92)
const C_TIE     := Color(0.72, 0.08, 0.08)
const C_SHOE    := Color(0.05, 0.05, 0.05)
const C_GLASS   := Color(0.10, 0.10, 0.10)
const C_LINE    := Color(0.05, 0.05, 0.05)
const C_WHITE   := Color.WHITE
const C_STAR    := Color(1.0, 0.85, 0.0)

# "normal" | "hit" | "critical" | "defeat"
var face_state: String = "normal":
	set(v):
		face_state = v
		queue_redraw()

func _draw() -> void:
	# --- shoes ---
	draw_rect(Rect2(-30, -7, 20, 7), C_SHOE)
	draw_rect(Rect2(10,  -7, 20, 7), C_SHOE)

	# --- legs ---
	draw_line(Vector2(  0, -55), Vector2(-15, -28), C_SUIT, 11)
	draw_line(Vector2(-15, -28), Vector2(-16,   0), C_SUIT, 10)
	draw_line(Vector2(  0, -55), Vector2( 15, -28), C_SUIT, 11)
	draw_line(Vector2( 15, -28), Vector2( 16,   0), C_SUIT, 10)

	# --- suit body ---
	var suit := PackedVector2Array([
		Vector2(-22, -58), Vector2(22, -58),
		Vector2(26, -112), Vector2(-26, -112)
	])
	draw_polygon(suit, PackedColorArray([C_SUIT]))

	# lapels
	var lpl := PackedVector2Array([
		Vector2(0, -112), Vector2(-13, -112), Vector2(-22, -91), Vector2(-5, -80)
	])
	var lpr := PackedVector2Array([
		Vector2(0, -112), Vector2( 13, -112), Vector2( 22, -91), Vector2( 5, -80)
	])
	draw_polygon(lpl, PackedColorArray([C_SHIRT]))
	draw_polygon(lpr, PackedColorArray([C_SHIRT]))

	# --- tie ---
	var tie := PackedVector2Array([
		Vector2(-4, -79), Vector2(4, -79),
		Vector2(6, -96), Vector2(3, -111), Vector2(-3, -111), Vector2(-6, -96)
	])
	draw_polygon(tie, PackedColorArray([C_TIE]))
	# knot
	var knot := PackedVector2Array([
		Vector2(-5, -111), Vector2(5, -111), Vector2(4, -118), Vector2(-4, -118)
	])
	draw_polygon(knot, PackedColorArray([C_TIE * Color(0.8,0.8,0.8,1)]))

	# --- arms ---
	draw_line(Vector2(-26, -108), Vector2(-37, -82), C_SUIT, 11)
	draw_line(Vector2(-37, -82), Vector2(-37, -60),  C_SUIT, 10)
	draw_line(Vector2( 26, -108), Vector2( 37, -82), C_SUIT, 11)
	draw_line(Vector2( 37, -82), Vector2( 37, -60),  C_SUIT, 10)
	draw_circle(Vector2(-37, -56), 7, C_SKIN)
	draw_circle(Vector2( 37, -56), 7, C_SKIN)

	# --- neck ---
	draw_rect(Rect2(-7, -127, 14, 18), C_SKIN)

	# --- head ---
	draw_circle(Vector2(0, -150), 27, C_SKIN)

	# --- hair (side parted) ---
	draw_arc(Vector2(0, -150), 27, deg_to_rad(180), deg_to_rad(358), 18, C_HAIR, 10)
	draw_line(Vector2(-5, -177), Vector2(-16, -162), C_HAIR, 5)

	# --- glasses ---
	draw_arc(Vector2(-11, -150), 7, 0, TAU, 12, C_GLASS, 2)
	draw_arc(Vector2( 11, -150), 7, 0, TAU, 12, C_GLASS, 2)
	draw_line(Vector2(-4, -150), Vector2(4, -150),    C_GLASS, 2)
	draw_line(Vector2(-18, -150), Vector2(-22, -148), C_GLASS, 2)
	draw_line(Vector2( 18, -150), Vector2( 22, -148), C_GLASS, 2)

	# --- face ---
	match face_state:
		"normal":   _face_normal()
		"hit":      _face_hit()
		"critical": _face_critical()
		"defeat":   _face_defeat()

func _face_normal() -> void:
	# smug look through glasses
	draw_circle(Vector2(-11, -150), 3, C_LINE)
	draw_circle(Vector2( 11, -150), 3, C_LINE)
	# smug half-smile
	draw_arc(Vector2(4, -137), 7, deg_to_rad(205), deg_to_rad(330), 8, C_LINE, 2)

func _face_hit() -> void:
	# X eyes (glasses pop off a bit - implied)
	var ox := 11.0; var oy := -150.0
	draw_line(Vector2(-ox-3, oy-3), Vector2(-ox+3, oy+3), C_LINE, 3)
	draw_line(Vector2(-ox+3, oy-3), Vector2(-ox-3, oy+3), C_LINE, 3)
	draw_line(Vector2( ox-3, oy-3), Vector2( ox+3, oy+3), C_LINE, 3)
	draw_line(Vector2( ox+3, oy-3), Vector2( ox-3, oy+3), C_LINE, 3)
	# open mouth of pain
	draw_arc(Vector2(0, -136), 8, deg_to_rad(15), deg_to_rad(165), 10, C_LINE, 3)
	# sweat drop
	draw_circle(Vector2(22, -162), 4, Color(0.5, 0.7, 1.0))

func _face_critical() -> void:
	# star eyes
	draw_circle(Vector2(-11, -150), 8, C_STAR)
	draw_circle(Vector2( 11, -150), 8, C_STAR)
	draw_circle(Vector2(-11, -150), 3, C_LINE)
	draw_circle(Vector2( 11, -150), 3, C_LINE)
	# big open aaah mouth
	draw_arc(Vector2(0, -134), 11, deg_to_rad(10), deg_to_rad(170), 12, C_LINE, 4)
	# stars floating
	draw_circle(Vector2(-28, -165), 4, C_STAR)
	draw_circle(Vector2( 28, -168), 3, C_STAR)
	draw_circle(Vector2(-22, -178), 3, C_STAR)

func _face_defeat() -> void:
	# X eyes
	var ox := 11.0; var oy := -150.0
	draw_line(Vector2(-ox-4, oy-4), Vector2(-ox+4, oy+4), C_LINE, 4)
	draw_line(Vector2(-ox+4, oy-4), Vector2(-ox-4, oy+4), C_LINE, 4)
	draw_line(Vector2( ox-4, oy-4), Vector2( ox+4, oy+4), C_LINE, 4)
	draw_line(Vector2( ox+4, oy-4), Vector2( ox-4, oy+4), C_LINE, 4)
	# wavy mouth
	var mx := -8.0; var my := -137.0
	for i in 4:
		var y_off := -3.0 if i % 2 == 0 else 3.0
		draw_line(Vector2(mx + i*4, my), Vector2(mx + i*4 + 4, my + y_off), C_LINE, 2)
	# glasses askew
	draw_arc(Vector2(-13, -147), 7, 0, TAU, 12, C_GLASS, 2)
	draw_arc(Vector2( 14, -153), 7, 0, TAU, 12, C_GLASS, 2)
