extends Node2D

const C_SKIN  := Color(1.00, 0.83, 0.62)
const C_HAIR  := Color(0.15, 0.10, 0.05)
const C_SHIRT := Color(0.25, 0.45, 0.95)
const C_PANTS := Color(0.15, 0.15, 0.30)
const C_SHOE  := Color(0.05, 0.05, 0.05)
const C_LINE  := Color(0.04, 0.04, 0.04)
const C_WOOD  := Color(0.55, 0.35, 0.12)
const C_CLUB  := Color(0.30, 0.18, 0.06)

var _lean: float = 0.0:
	set(v): _lean = v; queue_redraw()

func _draw() -> void:
	# shoes
	draw_rect(Rect2(-22, -8, 16, 8), C_SHOE)
	draw_rect(Rect2(6, -8, 16, 8), C_SHOE)
	# legs
	draw_line(Vector2(-8, -55), Vector2(-12, -28), C_PANTS, 10)
	draw_line(Vector2(-12, -28), Vector2(-14, 0), C_PANTS, 9)
	draw_line(Vector2(8, -55), Vector2(12, -28), C_PANTS, 10)
	draw_line(Vector2(12, -28), Vector2(14, 0), C_PANTS, 9)
	# torso
	draw_line(Vector2(0, -55), Vector2(0, -100), C_SHIRT, 18)
	# left arm (raised with club)
	var lean_off := Vector2(_lean * 10.0, 0.0)
	draw_line(Vector2(-9, -90) + lean_off, Vector2(-30, -115) + lean_off, C_SHIRT, 9)
	draw_line(Vector2(-30, -115) + lean_off, Vector2(-20, -140) + lean_off, C_SHIRT, 8)
	# right arm (balance)
	draw_line(Vector2(9, -90), Vector2(28, -110), C_SHIRT, 9)
	draw_line(Vector2(28, -110), Vector2(32, -90), C_SHIRT, 8)
	# club
	var hb := Vector2(-20, -140) + lean_off
	draw_line(hb, hb + Vector2(-10, -40), C_WOOD, 6)
	draw_circle(hb + Vector2(-14, -56), 12, C_CLUB)
	draw_circle(hb + Vector2(-14, -56), 8, C_CLUB * Color(1.2, 1.0, 0.8, 1))
	# neck
	draw_rect(Rect2(-7, -115, 14, 18), C_SKIN)
	# head
	draw_circle(Vector2(0, -132), 22, C_SKIN)
	# messy hair
	draw_arc(Vector2(0, -132), 22, deg_to_rad(180), deg_to_rad(360), 14, C_HAIR, 10)
	draw_line(Vector2(-5, -154), Vector2(-15, -140), C_HAIR, 4)
	draw_line(Vector2(8, -154), Vector2(18, -142), C_HAIR, 4)
	# angry eyes
	draw_line(Vector2(-10, -136), Vector2(-5, -133), C_LINE, 3)
	draw_line(Vector2(5, -133), Vector2(10, -136), C_LINE, 3)
	draw_circle(Vector2(-7, -131), 3, C_LINE)
	draw_circle(Vector2(7, -131), 3, C_LINE)
	# gritted teeth
	draw_rect(Rect2(-9, -122, 18, 7), Color(0.9, 0.9, 0.9))
	for i in 4:
		draw_line(Vector2(-8 + i*5, -122), Vector2(-8 + i*5, -115), C_LINE, 1)
