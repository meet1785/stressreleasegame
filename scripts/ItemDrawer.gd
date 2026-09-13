extends RefCounted
class_name ItemDrawer

## Vector-based cozy procedural renderer for diorama items and shop icons.
## Draws crisp, high-detail pastel illustrations directly on any CanvasItem.


static func draw_item(canvas: CanvasItem, item_id: String, center: Vector2, scale_factor: float = 1.0, anim_time: float = 0.0) -> void:
	match item_id:
		"succulent_plant":
			_draw_succulent(canvas, center, scale_factor, anim_time)
		"aromatherapy_candle":
			_draw_candle(canvas, center, scale_factor, anim_time)
		"cozy_tea_cup":
			_draw_tea_cup(canvas, center, scale_factor, anim_time)
		"sleeping_cat":
			_draw_cat(canvas, center, scale_factor, anim_time)
		"fairy_lights":
			_draw_fairy_lights(canvas, center, scale_factor, anim_time)
		"stack_of_books":
			_draw_books(canvas, center, scale_factor, anim_time)
		"bonsai_tree":
			_draw_bonsai(canvas, center, scale_factor, anim_time)
		"record_player":
			_draw_record_player(canvas, center, scale_factor, anim_time)
		"warm_floor_lamp":
			_draw_floor_lamp(canvas, center, scale_factor, anim_time)
		"plush_cushion":
			_draw_cushion(canvas, center, scale_factor, anim_time)
		"crystal_geode":
			_draw_crystal(canvas, center, scale_factor, anim_time)
		"herbal_terrarium":
			_draw_terrarium(canvas, center, scale_factor, anim_time)
		_:
			# Generic cute gift box placeholder if unknown
			_draw_placeholder(canvas, center, scale_factor)


static func _draw_succulent(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 30 * s), 36 * s, Color(0, 0, 0, 0.15))
	# Ceramic Saucer
	c.draw_circle(pos + Vector2(0, 26 * s), 32 * s, Color("#D4C4B5"))
	# Ceramic Pot (trapezoid)
	var pot_points := PackedVector2Array([
		pos + Vector2(-28 * s, -2 * s),
		pos + Vector2(28 * s, -2 * s),
		pos + Vector2(20 * s, 26 * s),
		pos + Vector2(-20 * s, 26 * s)
	])
	c.draw_colored_polygon(pot_points, Color("#E8DACB"))
	# Pot Rim
	c.draw_circle(pos + Vector2(0, -2 * s), 28 * s, Color("#DFC9B6"))
	# Soil
	c.draw_circle(pos + Vector2(0, -2 * s), 22 * s, Color("#5A3E2B"))

	# Succulent Leaves (Layers)
	var petal_count := 8
	for i in petal_count:
		var angle := (TAU / float(petal_count)) * float(i)
		var leaf_pos := pos + Vector2(cos(angle), sin(angle)) * (16 * s) + Vector2(0, -10 * s)
		c.draw_circle(leaf_pos, 10 * s, Color("#6B9080"))
		c.draw_circle(leaf_pos + Vector2(0, -2 * s), 4 * s, Color("#F6BD60", 0.7)) # Blush tip

	# Center bud
	var bob := sin(anim * 2.0) * (1.5 * s)
	c.draw_circle(pos + Vector2(0, -12 * s + bob), 12 * s, Color("#84A98C"))
	c.draw_circle(pos + Vector2(-3 * s, -14 * s + bob), 4 * s, Color("#A7C957"))


static func _draw_candle(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 28 * s), 30 * s, Color(0, 0, 0, 0.12))
	# Glass Jar
	var jar_points := PackedVector2Array([
		pos + Vector2(-22 * s, -18 * s),
		pos + Vector2(22 * s, -18 * s),
		pos + Vector2(22 * s, 26 * s),
		pos + Vector2(-22 * s, 26 * s)
	])
	c.draw_colored_polygon(jar_points, Color(0.9, 0.88, 0.95, 0.45))
	# Wax fill
	var wax_points := PackedVector2Array([
		pos + Vector2(-20 * s, -8 * s),
		pos + Vector2(20 * s, -8 * s),
		pos + Vector2(20 * s, 24 * s),
		pos + Vector2(-20 * s, 24 * s)
	])
	c.draw_colored_polygon(wax_points, Color("#E2CCE8"))
	# Wick
	c.draw_line(pos + Vector2(0, -8 * s), pos + Vector2(0, -18 * s), Color("#3E2723"), 3 * s)

	# Flame flicker
	var flicker := sin(anim * 8.0) * (2.5 * s)
	var flame_height := 14 * s + cos(anim * 11.0) * (2.0 * s)
	var flame_pos := pos + Vector2(flicker * 0.4, -26 * s)
	# Warm ambient glow aura
	c.draw_circle(flame_pos, 28 * s + sin(anim * 6.0) * (3 * s), Color(1.0, 0.85, 0.4, 0.25))
	# Outer Flame
	c.draw_circle(flame_pos, 9 * s, Color("#FFB703"))
	# Inner White core
	c.draw_circle(flame_pos + Vector2(0, 2 * s), 4 * s, Color("#FFF3B0"))


static func _draw_tea_cup(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 24 * s), 34 * s, Color(0, 0, 0, 0.12))
	# Saucer
	c.draw_circle(pos + Vector2(0, 20 * s), 32 * s, Color("#E9D8A6"))
	# Mug Handle
	c.draw_arc(pos + Vector2(24 * s, 4 * s), 12 * s, -PI * 0.4, PI * 0.4, 16, Color("#94D2BD"), 5 * s)
	# Mug body
	var mug_points := PackedVector2Array([
		pos + Vector2(-24 * s, -14 * s),
		pos + Vector2(24 * s, -14 * s),
		pos + Vector2(18 * s, 18 * s),
		pos + Vector2(-18 * s, 18 * s)
	])
	c.draw_colored_polygon(mug_points, Color("#94D2BD"))
	# Tea liquid
	c.draw_circle(pos + Vector2(0, -14 * s), 21 * s, Color("#CA6702"))
	# Lemon slice
	c.draw_circle(pos + Vector2(-8 * s, -14 * s), 7 * s, Color("#E9D8A6"))
	c.draw_circle(pos + Vector2(-8 * s, -14 * s), 5 * s, Color("#EE9B00"))

	# Steam curls
	for i in 2:
		var x_off := -6.0 * s if i == 0 else 6.0 * s
		var steam_phase := anim * 3.0 + float(i) * 2.0
		var y_off := -22 * s - fmod(steam_phase * 10.0, 30.0 * s)
		var swiggle := sin(steam_phase) * (4.0 * s)
		c.draw_circle(pos + Vector2(x_off + swiggle, y_off), 3 * s, Color(1, 1, 1, 0.4))


static func _draw_cat(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 18 * s), 36 * s, Color(0, 0, 0, 0.12))
	# Pillow/bed
	c.draw_circle(pos + Vector2(0, 14 * s), 34 * s, Color("#E0B1CB"))

	# Cat body (breathing expansion)
	var breath := sin(anim * 2.5) * (1.2 * s)
	c.draw_circle(pos + Vector2(0, 2 * s), 24 * s + breath, Color("#F4A261"))

	# Curled tail
	c.draw_arc(pos + Vector2(-18 * s, 10 * s), 12 * s, 0, PI * 0.9, 16, Color("#E76F51"), 6 * s)

	# Cat head
	var head_pos := pos + Vector2(10 * s, -6 * s + breath * 0.5)
	c.draw_circle(head_pos, 15 * s, Color("#F4A261"))
	# Ears
	var ear_l := PackedVector2Array([head_pos + Vector2(-10 * s, -10 * s), head_pos + Vector2(-14 * s, -22 * s), head_pos + Vector2(-2 * s, -14 * s)])
	var ear_r := PackedVector2Array([head_pos + Vector2(2 * s, -14 * s), head_pos + Vector2(10 * s, -22 * s), head_pos + Vector2(12 * s, -8 * s)])
	c.draw_colored_polygon(ear_l, Color("#E76F51"))
	c.draw_colored_polygon(ear_r, Color("#E76F51"))
	# Sleeping eyes (curved arcs)
	c.draw_arc(head_pos + Vector2(-4 * s, 0), 4 * s, PI * 0.1, PI * 0.9, 8, Color("#3D1C06"), 2 * s)
	c.draw_arc(head_pos + Vector2(6 * s, 0), 4 * s, PI * 0.1, PI * 0.9, 8, Color("#3D1C06"), 2 * s)
	# Nose
	c.draw_circle(head_pos + Vector2(1 * s, 4 * s), 2.5 * s, Color("#FFB4A2"))


static func _draw_fairy_lights(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Hanging wire arch
	var p1 := pos + Vector2(-36 * s, -20 * s)
	var p2 := pos + Vector2(0, 4 * s)
	var p3 := pos + Vector2(36 * s, -20 * s)
	c.draw_line(p1, p2, Color("#4A5568"), 2 * s)
	c.draw_line(p2, p3, Color("#4A5568"), 2 * s)

	var bulb_colors := [Color("#F4A261"), Color("#E9C46A"), Color("#2A9D8F"), Color("#E76F51"), Color("#E0AAFF")]
	var bulb_positions := [
		pos + Vector2(-30 * s, -16 * s),
		pos + Vector2(-15 * s, -6 * s),
		pos + Vector2(0, 4 * s),
		pos + Vector2(15 * s, -6 * s),
		pos + Vector2(30 * s, -16 * s)
	]

	for i in bulb_positions.size():
		var b_pos: Vector2 = bulb_positions[i]
		var col: Color = bulb_colors[i % bulb_colors.size()]
		var pulse := sin(anim * 4.0 + float(i) * 1.2) * (2.0 * s)
		# Glow aura
		c.draw_circle(b_pos, 12 * s + pulse, Color(col.r, col.g, col.b, 0.35))
		# Bulb core
		c.draw_circle(b_pos, 5 * s, col)
		c.draw_circle(b_pos + Vector2(-1 * s, -1 * s), 2 * s, Color.WHITE)


static func _draw_books(c: CanvasItem, pos: Vector2, s: float, _anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 24 * s), 36 * s, Color(0, 0, 0, 0.12))

	# Book 1 (bottom, wide sage)
	var b1 := Rect2(pos.x - 32 * s, pos.y + 8 * s, 64 * s, 14 * s)
	c.draw_rect(b1, Color("#52796F"))
	c.draw_rect(Rect2(pos.x - 30 * s, pos.y + 10 * s, 60 * s, 10 * s), Color("#CAD2C5"))
	c.draw_rect(Rect2(pos.x - 32 * s, pos.y + 8 * s, 8 * s, 14 * s), Color("#354F52"))

	# Book 2 (middle, dusty rose)
	var b2 := Rect2(pos.x - 26 * s, pos.y - 6 * s, 52 * s, 14 * s)
	c.draw_rect(b2, Color("#B5838D"))
	c.draw_rect(Rect2(pos.x - 24 * s, pos.y - 4 * s, 48 * s, 10 * s), Color("#F4ECE1"))
	c.draw_rect(Rect2(pos.x - 26 * s, pos.y - 6 * s, 7 * s, 14 * s), Color("#6D6875"))

	# Book 3 (top, navy with gold)
	var b3 := Rect2(pos.x - 20 * s, pos.y - 20 * s, 40 * s, 13 * s)
	c.draw_rect(b3, Color("#1D3557"))
	c.draw_rect(Rect2(pos.x - 18 * s, pos.y - 18 * s, 36 * s, 9 * s), Color("#FFF1E6"))
	c.draw_rect(Rect2(pos.x - 20 * s, pos.y - 20 * s, 6 * s, 13 * s), Color("#457B9D"))

	# Ribbon bookmark hanging
	c.draw_line(pos + Vector2(10 * s, -14 * s), pos + Vector2(16 * s, 16 * s), Color("#E63946"), 3 * s)


static func _draw_bonsai(c: CanvasItem, pos: Vector2, s: float, _anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 26 * s), 34 * s, Color(0, 0, 0, 0.12))
	# Ceramic planter tray
	var tray := Rect2(pos.x - 28 * s, pos.y + 14 * s, 56 * s, 12 * s)
	c.draw_rect(tray, Color("#3A5A40"))
	# Moss mound
	c.draw_circle(pos + Vector2(0, 14 * s), 24 * s, Color("#588157"))

	# Gnarled trunk
	c.draw_line(pos + Vector2(0, 14 * s), pos + Vector2(-8 * s, -4 * s), Color("#4A3B32"), 8 * s)
	c.draw_line(pos + Vector2(-8 * s, -4 * s), pos + Vector2(6 * s, -18 * s), Color("#4A3B32"), 6 * s)

	# Foliage cloud puffs
	c.draw_circle(pos + Vector2(-16 * s, -10 * s), 14 * s, Color("#386641"))
	c.draw_circle(pos + Vector2(8 * s, -24 * s), 18 * s, Color("#6A994E"))
	c.draw_circle(pos + Vector2(18 * s, -14 * s), 12 * s, Color("#A7C957"))


static func _draw_record_player(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 22 * s), 36 * s, Color(0, 0, 0, 0.12))
	# Wood body
	var box := Rect2(pos.x - 30 * s, pos.y - 16 * s, 60 * s, 36 * s)
	c.draw_rect(box, Color("#8D5B4C"))
	c.draw_rect(Rect2(pos.x - 28 * s, pos.y - 14 * s, 56 * s, 32 * s), Color("#A26756"))

	# Vinyl disc
	c.draw_circle(pos + Vector2(-8 * s, 2 * s), 16 * s, Color("#1A1A1A"))
	c.draw_circle(pos + Vector2(-8 * s, 2 * s), 6 * s, Color("#E76F51")) # Label
	c.draw_circle(pos + Vector2(-8 * s, 2 * s), 2 * s, Color.WHITE)

	# Animated spin reflection
	var spin_angle := anim * 4.0
	var refl_pos := pos + Vector2(-8 * s, 2 * s) + Vector2(cos(spin_angle), sin(spin_angle)) * (10 * s)
	c.draw_circle(refl_pos, 2 * s, Color(1, 1, 1, 0.5))

	# Tonearm
	c.draw_line(pos + Vector2(18 * s, -8 * s), pos + Vector2(-4 * s, 2 * s), Color("#D4AF37"), 2.5 * s)
	c.draw_circle(pos + Vector2(18 * s, -8 * s), 4 * s, Color("#B5942F"))


static func _draw_floor_lamp(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 28 * s), 24 * s, Color(0, 0, 0, 0.12))
	# Base
	c.draw_circle(pos + Vector2(0, 26 * s), 16 * s, Color("#D4AF37"))
	# Stand pole
	c.draw_line(pos + Vector2(0, 26 * s), pos + Vector2(0, -22 * s), Color("#D4AF37"), 3.5 * s)

	# Ambient floor light cone
	var light_alpha := 0.2 + sin(anim * 3.0) * 0.04
	c.draw_circle(pos + Vector2(0, 24 * s), 38 * s, Color(1.0, 0.92, 0.6, light_alpha))

	# Lampshade (trapezoid)
	var shade_points := PackedVector2Array([
		pos + Vector2(-12 * s, -38 * s),
		pos + Vector2(12 * s, -38 * s),
		pos + Vector2(22 * s, -18 * s),
		pos + Vector2(-22 * s, -18 * s)
	])
	c.draw_colored_polygon(shade_points, Color("#FFF1D0"))
	c.draw_circle(pos + Vector2(0, -18 * s), 20 * s, Color(1.0, 0.85, 0.4, 0.45))


static func _draw_cushion(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 20 * s), 36 * s, Color(0, 0, 0, 0.14))
	# Squishy cushion body
	var squish := sin(anim * 1.8) * (1.0 * s)
	c.draw_circle(pos + Vector2(0, 4 * s), 30 * s + squish, Color("#74A57F"))
	c.draw_circle(pos + Vector2(0, 2 * s), 26 * s + squish, Color("#84A98C"))

	# Crease radiating lines
	for i in 6:
		var a := (TAU / 6.0) * float(i)
		var p1 := pos + Vector2(cos(a), sin(a)) * (8 * s)
		var p2 := pos + Vector2(cos(a), sin(a)) * (24 * s)
		c.draw_line(p1, p2, Color("#52796F", 0.5), 2 * s)

	# Center button
	c.draw_circle(pos + Vector2(0, 2 * s), 5 * s, Color("#354F52"))


static func _draw_crystal(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 24 * s), 32 * s, Color(0, 0, 0, 0.12))
	# Geode stone rock base
	c.draw_circle(pos + Vector2(0, 16 * s), 28 * s, Color("#4A4E69"))

	# Amethyst Crystal spikes
	var c1 := PackedVector2Array([pos + Vector2(-16 * s, 14 * s), pos + Vector2(-10 * s, -26 * s), pos + Vector2(-2 * s, 12 * s)])
	var c2 := PackedVector2Array([pos + Vector2(-4 * s, 14 * s), pos + Vector2(6 * s, -34 * s), pos + Vector2(14 * s, 12 * s)])
	var c3 := PackedVector2Array([pos + Vector2(10 * s, 14 * s), pos + Vector2(22 * s, -18 * s), pos + Vector2(26 * s, 16 * s)])

	c.draw_colored_polygon(c1, Color("#7209B7"))
	c.draw_colored_polygon(c2, Color("#9D4EDD"))
	c.draw_colored_polygon(c3, Color("#5A189A"))

	# Sparkling glint
	var sparkle_pulse := sin(anim * 5.0) * (2.0 * s)
	c.draw_circle(pos + Vector2(6 * s, -34 * s), 3 * s + sparkle_pulse, Color("#E0AAFF"))
	c.draw_circle(pos + Vector2(6 * s, -34 * s), 1.5 * s, Color.WHITE)


static func _draw_terrarium(c: CanvasItem, pos: Vector2, s: float, anim: float) -> void:
	# Shadow
	c.draw_circle(pos + Vector2(0, 26 * s), 34 * s, Color(0, 0, 0, 0.14))
	# Wood base
	c.draw_circle(pos + Vector2(0, 22 * s), 30 * s, Color("#7F5539"))
	# Moss mound
	c.draw_circle(pos + Vector2(0, 14 * s), 24 * s, Color("#588157"))

	# Tiny mushrooms
	c.draw_circle(pos + Vector2(-8 * s, 8 * s), 5 * s, Color("#E76F51"))
	c.draw_circle(pos + Vector2(8 * s, 10 * s), 4 * s, Color("#F4A261"))

	# Glass cloche dome
	c.draw_circle(pos + Vector2(0, -6 * s), 24 * s, Color(0.7, 0.9, 1.0, 0.28))
	# Glass dome reflection arc
	c.draw_arc(pos + Vector2(0, -6 * s), 22 * s, -PI * 0.75, -PI * 0.25, 16, Color(1, 1, 1, 0.5), 2.5 * s)
	# Finial top handle
	c.draw_circle(pos + Vector2(0, -32 * s), 4 * s, Color(0.8, 0.9, 1.0, 0.6))


static func _draw_placeholder(c: CanvasItem, pos: Vector2, s: float) -> void:
	c.draw_circle(pos + Vector2(0, 20 * s), 24 * s, Color(0, 0, 0, 0.12))
	var box := Rect2(pos.x - 20 * s, pos.y - 16 * s, 40 * s, 32 * s)
	c.draw_rect(box, Color("#E0B1CB"))
	c.draw_circle(pos, 8 * s, Color("#BE95C4"))
