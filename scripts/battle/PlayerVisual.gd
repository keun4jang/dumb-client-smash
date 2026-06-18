extends Node2D

const C_SKIN    := Color(1.00, 0.83, 0.62)
const C_HAIR    := Color(0.22, 0.14, 0.06)
const C_SHIRT   := Color(0.20, 0.35, 0.82)
const C_PANTS   := Color(0.16, 0.16, 0.36)
const C_SHOE    := Color(0.08, 0.08, 0.08)
const C_WOOD    := Color(0.55, 0.28, 0.08)
const C_CLUB    := Color(0.28, 0.13, 0.03)
const C_NAIL    := Color(0.75, 0.75, 0.75)
const C_LINE    := Color(0.05, 0.05, 0.05)
const C_WHITE   := Color.WHITE

# 0 = idle, 1 = full forward swing
var _t: float = 0.0:
	set(v):
		_t = v
		queue_redraw()

func _draw() -> void:
	# feet at y=0, character extends upward

	# --- shoes ---
	draw_rect(Rect2(-36, -9, 24, 9), C_SHOE)
	draw_rect(Rect2(12,  -9, 24, 9), C_SHOE)

	# --- legs ---
	draw_line(Vector2(  0, -62), Vector2(-18, -30), C_PANTS, 11)
	draw_line(Vector2(-18, -30), Vector2(-20,   0), C_PANTS, 10)
	draw_line(Vector2(  0, -62), Vector2( 18, -30), C_PANTS, 11)
	draw_line(Vector2( 18, -30), Vector2( 20,   0), C_PANTS, 10)

	# --- torso (work shirt, sleeves rolled up) ---
	var torso := PackedVector2Array([
		Vector2(-24, -65), Vector2(24, -65),
		Vector2(28, -118), Vector2(-28, -118)
	])
	draw_polygon(torso, PackedColorArray([C_SHIRT, C_SHIRT, C_SHIRT, C_SHIRT]))

	# shirt pocket
	draw_rect(Rect2(-24, -100, 12, 10), C_SHIRT * Color(0.88, 0.88, 0.88, 1))
	draw_line(Vector2(-24, -100), Vector2(-12, -100), C_LINE, 1)
	draw_line(Vector2(-24, -100), Vector2(-24, -90),  C_LINE, 1)
	draw_line(Vector2(-12, -100), Vector2(-12, -90),  C_LINE, 1)

	# --- neck ---
	draw_rect(Rect2(-8, -132, 16, 18), C_SKIN)

	# --- head ---
	draw_circle(Vector2(0, -156), 27, C_SKIN)

	# --- messy hair ---
	draw_arc(Vector2(0, -156), 27, deg_to_rad(178), deg_to_rad(360), 20, C_HAIR, 10)
	draw_circle(Vector2( 0, -183), 13, C_HAIR)
	draw_circle(Vector2(-14, -176), 8,  C_HAIR)
	draw_circle(Vector2( 16, -174), 7,  C_HAIR)

	# --- face (determined / angry) ---
	# angry eyebrows
	draw_line(Vector2(-14, -165), Vector2(-5, -161), C_LINE, 3)
	draw_line(Vector2(  5, -161), Vector2(14, -165), C_LINE, 3)
	# eyes
	draw_circle(Vector2(-9, -157), 5, C_LINE)
	draw_circle(Vector2( 9, -157), 5, C_LINE)
	draw_circle(Vector2(-8, -157), 2, C_WHITE)
	draw_circle(Vector2( 8, -157), 2, C_WHITE)
	# gritted teeth
	draw_rect(Rect2(-10, -149, 20, 7), C_WHITE)
	draw_line(Vector2(-10, -146), Vector2(10, -146), C_LINE, 2)
	for i in 5:
		draw_line(Vector2(-8 + i * 4, -149), Vector2(-8 + i * 4, -142), C_LINE, 1)
	draw_rect(Rect2(-10, -149, 20, 7), Color(0,0,0,0))  # border
	draw_line(Vector2(-10,-149), Vector2(10,-149), C_LINE, 2)
	draw_line(Vector2(-10,-142), Vector2(10,-142), C_LINE, 2)

	# --- arm / club swing ---
	# t=0: idle (club resting behind right shoulder)
	# t=0..0.4: windup (arm sweeps back-up)
	# t=0.4..1.0: swing forward hard

	var swing_deg: float
	if _t < 0.4:
		swing_deg = lerp(25.0, 175.0, _t / 0.4)
	else:
		swing_deg = lerp(175.0, -55.0, (_t - 0.4) / 0.6)

	var ang := deg_to_rad(swing_deg)
	var shoulder := Vector2(28, -115)
	var elbow    := shoulder + Vector2(cos(ang) * 38, sin(ang) * 38)
	var hand     := elbow   + Vector2(cos(ang + 0.28) * 32, sin(ang + 0.28) * 32)

	# sleeve (rolled up = skin colour from elbow down)
	draw_line(shoulder, elbow, C_SHIRT, 12)
	draw_line(elbow,    hand,  C_SKIN,  11)

	# club handle
	var club_ang := ang + 0.18
	var cdir := Vector2(cos(club_ang), sin(club_ang))
	draw_line(hand, hand + cdir * 55, C_WOOD, 12)

	# club head (fat rounded rectangle)
	var hb := hand + cdir * 55
	var perp := Vector2(-cdir.y, cdir.x)
	var head_pts := PackedVector2Array([
		hb + perp * 14  - cdir * 2,
		hb - perp * 14  - cdir * 2,
		hb - perp * 11  + cdir * 30,
		hb + perp * 11  + cdir * 30,
	])
	draw_polygon(head_pts, PackedColorArray([C_CLUB, C_CLUB, C_CLUB, C_CLUB]))
	draw_circle(hb + cdir * 15, 14, C_CLUB)

	# nails on club (visible only during fast swing)
	if _t > 0.75:
		draw_circle(hb + cdir * 10 + perp * 6,  3, C_NAIL)
		draw_circle(hb + cdir * 10 - perp * 6,  3, C_NAIL)
		draw_circle(hb + cdir * 22,              3, C_NAIL)

	# --- left arm (counterbalance) ---
	var l_base := deg_to_rad(lerp(195.0, 145.0, _t))
	var l_shoulder := Vector2(-28, -115)
	var l_elbow    := l_shoulder + Vector2(cos(l_base) * 36, sin(l_base) * 36)
	var l_hand     := l_elbow   + Vector2(cos(l_base - 0.4) * 28, sin(l_base - 0.4) * 28)
	draw_line(l_shoulder, l_elbow, C_SHIRT, 12)
	draw_line(l_elbow,    l_hand,  C_SKIN,  11)

# Call this from Player.gd on each tap
func play_attack(is_critical: bool) -> void:
	var speed := 0.055 if is_critical else 0.075
	var tw := create_tween()
	tw.tween_property(self, "_t", 0.38, speed * 0.7)
	tw.tween_property(self, "_t", 1.0, speed).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_t", 0.0, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
