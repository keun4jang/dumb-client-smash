extends Node2D

const C_SKIN   := Color(1.00, 0.76, 0.56)
const C_HAIR   := Color(0.60, 0.48, 0.00)   # gold-grey
const C_SUIT   := Color(0.08, 0.08, 0.18)   # dark navy
const C_SHIRT  := Color(0.95, 0.95, 0.95)
const C_TIE    := Color(0.85, 0.04, 0.04)   # power red
const C_SHOE   := Color(0.04, 0.04, 0.04)
const C_GOLD   := Color(0.80, 0.65, 0.10)   # gold glasses
const C_LINE   := Color(0.04, 0.04, 0.04)
const C_WHITE  := Color.WHITE
const C_RED    := Color(0.9, 0.1, 0.0)

# "idle" | "charging" | "hit" | "defeat"
var face_state: String = "idle":
	set(v):
		face_state = v
		queue_redraw()

func _draw() -> void:
	# Boss is bigger than enemy — wider stance, more imposing

	# --- shoes ---
	draw_rect(Rect2(-42, -10, 28, 10), C_SHOE)
	draw_rect(Rect2(14,  -10, 28, 10), C_SHOE)

	# --- legs (wide powerful stance) ---
	draw_line(Vector2(  0, -70), Vector2(-24, -34), C_SUIT, 16)
	draw_line(Vector2(-24, -34), Vector2(-26,   0), C_SUIT, 14)
	draw_line(Vector2(  0, -70), Vector2( 24, -34), C_SUIT, 16)
	draw_line(Vector2( 24, -34), Vector2( 26,   0), C_SUIT, 14)

	# --- suit body (broad shoulders) ---
	var suit := PackedVector2Array([
		Vector2(-34, -74), Vector2(34, -74),
		Vector2(42, -135), Vector2(-42, -135)
	])
	draw_polygon(suit, PackedColorArray([C_SUIT]))

	# shirt & lapels
	var lpl := PackedVector2Array([
		Vector2(0, -135), Vector2(-16, -135), Vector2(-30, -103), Vector2(-8, -86)
	])
	var lpr := PackedVector2Array([
		Vector2(0, -135), Vector2( 16, -135), Vector2( 30, -103), Vector2( 8, -86)
	])
	draw_polygon(lpl, PackedColorArray([C_SHIRT]))
	draw_polygon(lpr, PackedColorArray([C_SHIRT]))

	# --- power tie (wide, with stripe pattern) ---
	var tie := PackedVector2Array([
		Vector2(-7, -84),  Vector2(7, -84),
		Vector2(10, -110), Vector2(5, -133), Vector2(-5, -133), Vector2(-10, -110)
	])
	draw_polygon(tie, PackedColorArray([C_TIE]))
	# stripe details
	for i in 3:
		var yy := -95.0 - i * 11.0
		draw_line(Vector2(-8, yy), Vector2(8, yy + 2), C_TIE * Color(0.65,0.65,0.65,1), 2)
	# knot
	var knot := PackedVector2Array([
		Vector2(-7, -133), Vector2(7, -133), Vector2(5, -142), Vector2(-5, -142)
	])
	draw_polygon(knot, PackedColorArray([C_TIE * Color(0.82,0.82,0.82,1)]))

	# cufflinks detail
	draw_circle(Vector2(-48, -68), 5, C_GOLD)
	draw_circle(Vector2( 48, -68), 5, C_GOLD)

	# --- arms (thick, imposing) ---
	draw_line(Vector2(-42, -130), Vector2(-56, -98), C_SUIT, 17)
	draw_line(Vector2(-56, -98), Vector2(-58, -68),  C_SUIT, 15)
	draw_line(Vector2( 42, -130), Vector2( 56, -98), C_SUIT, 17)
	draw_line(Vector2( 56, -98), Vector2( 58, -68),  C_SUIT, 15)
	# fists
	draw_circle(Vector2(-58, -63), 11, C_SKIN)
	draw_circle(Vector2( 58, -63), 11, C_SKIN)

	# --- neck (thick) ---
	draw_rect(Rect2(-12, -152, 24, 22), C_SKIN)

	# --- head (big, jowly) ---
	draw_circle(Vector2(0, -180), 38, C_SKIN)
	# jowls
	draw_circle(Vector2(-28, -168), 16, C_SKIN)
	draw_circle(Vector2( 28, -168), 16, C_SKIN)

	# --- hair (thin on top, receding) ---
	draw_arc(Vector2(0, -180), 38, deg_to_rad(200), deg_to_rad(340), 16, C_HAIR, 13)
	draw_line(Vector2(-18, -217), Vector2(18, -216), C_HAIR, 6)
	draw_line(Vector2(-10, -218), Vector2(-22, -205), C_HAIR, 4)

	# --- gold-rim glasses ---
	draw_arc(Vector2(-15, -180), 10, 0, TAU, 14, C_GOLD, 3)
	draw_arc(Vector2( 15, -180), 10, 0, TAU, 14, C_GOLD, 3)
	draw_line(Vector2(-5, -180), Vector2(5, -180),   C_GOLD, 3)
	draw_line(Vector2(-25, -178), Vector2(-30, -176), C_GOLD, 3)
	draw_line(Vector2( 25, -178), Vector2( 30, -176), C_GOLD, 3)

	# --- thick brows ---
	draw_line(Vector2(-22, -195), Vector2(-6, -190),  C_LINE, 6)
	draw_line(Vector2(  6, -190), Vector2(22, -195),  C_LINE, 6)

	# --- face ---
	match face_state:
		"idle":     _face_idle()
		"charging": _face_charging()
		"hit":      _face_hit()
		"defeat":   _face_defeat()

func _face_idle() -> void:
	# cold intimidating stare through glasses
	draw_circle(Vector2(-15, -180), 4, C_LINE)
	draw_circle(Vector2( 15, -180), 4, C_LINE)
	# thin pressed-lip smirk
	draw_line(Vector2(-8, -163), Vector2(12, -161), C_LINE, 3)

func _face_charging() -> void:
	# wide angry glare, veins visible
	draw_circle(Vector2(-15, -180), 7, C_RED)
	draw_circle(Vector2( 15, -180), 7, C_RED)
	draw_circle(Vector2(-15, -180), 2, C_LINE)
	draw_circle(Vector2( 15, -180), 2, C_LINE)
	# bared teeth
	draw_rect(Rect2(-14, -167, 28, 9), C_WHITE)
	for i in 6:
		draw_line(Vector2(-12 + i*5, -167), Vector2(-12 + i*5, -158), C_LINE, 2)
	draw_line(Vector2(-14,-167), Vector2(14,-167), C_LINE, 2)
	draw_line(Vector2(-14,-158), Vector2(14,-158), C_LINE, 2)
	# forehead vein
	draw_line(Vector2(-30, -205), Vector2(-22, -198), C_RED * Color(0.7,0.7,0.7,1), 3)
	draw_line(Vector2(-22, -198), Vector2(-26, -192), C_RED * Color(0.7,0.7,0.7,1), 3)

func _face_hit() -> void:
	# X eyes
	var pts := [Vector2(-15,-180), Vector2(15,-180)]
	for p in pts:
		draw_line(p + Vector2(-5,-5), p + Vector2(5,5), C_LINE, 4)
		draw_line(p + Vector2(5,-5),  p + Vector2(-5,5), C_LINE, 4)
	# O mouth
	draw_arc(Vector2(0, -162), 10, deg_to_rad(5), deg_to_rad(175), 12, C_LINE, 4)

func _face_defeat() -> void:
	# X eyes
	var pts := [Vector2(-15,-180), Vector2(15,-180)]
	for p in pts:
		draw_line(p + Vector2(-5,-5), p + Vector2(5,5), C_LINE, 4)
		draw_line(p + Vector2(5,-5),  p + Vector2(-5,5), C_LINE, 4)
	# spiral / dizzy lines
	draw_arc(Vector2(0, -162), 8,  deg_to_rad(0),   deg_to_rad(270), 12, C_LINE, 3)
	draw_arc(Vector2(0, -162), 4,  deg_to_rad(90),  deg_to_rad(360), 8,  C_LINE, 2)
	# sweat drops
	draw_circle(Vector2(-42, -195), 5, Color(0.5,0.7,1.0))
	draw_circle(Vector2( 42, -198), 4, Color(0.5,0.7,1.0))
