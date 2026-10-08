extends Control

var _clock := 0.0
var _pulse := 0.0
var _prestige_concentration := 0.0
var _prestige_burst := 0.0
var _production_activity := 0.0
var _target_production_activity := 0.0
var _visual_level := -1
var _visual_tier := 0.0
var _target_visual_tier := 0.0
var _multiplier_text := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func set_production_rate(rate: float) -> void:
	_target_production_activity = clampf(log(maxf(rate, 1.0)) / log(100000.0), 0.0, 1.0)
	queue_redraw()

func set_visual_level(total_upgrade_level: int) -> void:
	if total_upgrade_level == _visual_level:
		return
	_visual_level = maxi(0, total_upgrade_level)
	_target_visual_tier = float(get_visual_stage(_visual_level) - 1)
	queue_redraw()

func get_visual_stage(total_upgrade_level: int) -> int:
	if total_upgrade_level >= 300:
		return 5
	if total_upgrade_level >= 150:
		return 4
	if total_upgrade_level >= 75:
		return 3
	if total_upgrade_level >= 25:
		return 2
	return 1

func set_multiplier_text(value: String) -> void:
	_multiplier_text = value
	queue_redraw()

func trigger_pulse() -> void:
	_pulse = 1.0
	queue_redraw()

func set_prestige_concentration(value: float) -> void:
	_prestige_concentration = clampf(value, 0.0, 1.0)
	queue_redraw()

func set_prestige_burst(value: float) -> void:
	_prestige_burst = clampf(value, 0.0, 1.0)
	queue_redraw()

func _process(delta: float) -> void:
	_clock += delta
	_pulse = move_toward(_pulse, 0.0, delta * 1.8)
	_prestige_burst = move_toward(_prestige_burst, 0.0, delta * 2.8)
	_production_activity = move_toward(_production_activity, _target_production_activity, delta * 0.55)
	_visual_tier = move_toward(_visual_tier, _target_visual_tier, delta * 0.9)
	queue_redraw()

func _draw() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.44)
	# Keep the largest orbit inside the ReactorCore rect so it cannot cover the purchase controls above it.
	var radius := minf(size.x * 0.19, size.y * 0.30)
	if radius < 20.0:
		return
	var tier_activity := clampf(_visual_tier / 4.0, 0.0, 1.0)
	var activity := maxf(_production_activity, tier_activity * 0.78)
	var spin_speed := 0.28 + activity * 1.1 + _prestige_concentration * 1.7 + _prestige_burst * 0.45
	var breathing := sin(_clock * (1.7 + activity * 1.0))
	var pulse_scale := 1.0 + breathing * 0.018 + _pulse * 0.028 - _prestige_concentration * 0.055 + _prestige_burst * 0.08
	var hot_orange := Color(1.0, 0.65, 0.29)
	var dim_orange := Color(0.43, 0.20, 0.10, 0.68)
	var metal := Color(0.26, 0.28, 0.27, 0.88)
	var cyan := Color(0.30, 0.68, 0.63, 0.78)
	var orbit_scale := 1.0 - _prestige_concentration * 0.28 + _prestige_burst * 0.07
	var second_ring := clampf(_visual_tier, 0.0, 1.0)
	var node_progress := clampf(_visual_tier - 1.0, 0.0, 1.0)
	var bright_progress := clampf(_visual_tier - 2.0, 0.0, 1.0)
	var apex_progress := clampf(_visual_tier - 3.0, 0.0, 1.0)

	# A few broad, rotating rings give the core a game-like silhouette without a boxed dashboard frame.
	draw_circle(center, radius * 1.18 * pulse_scale, Color(0.78, 0.24, 0.06, 0.035 + _pulse * 0.055 + _prestige_burst * 0.07))
	draw_arc(center, radius * 1.34 * orbit_scale, 0.0, TAU, 96, Color(0.30, 0.32, 0.29, 0.75), 3.0)
	draw_arc(center, radius * 1.22 * orbit_scale, _clock * spin_speed, _clock * spin_speed + TAU * 0.70, 80, dim_orange, 5.0)
	draw_arc(center, radius * 1.22 * orbit_scale, -_clock * spin_speed * 0.62, -_clock * spin_speed * 0.62 + TAU * 0.20, 36, hot_orange.lightened(bright_progress * 0.12 + _prestige_burst * 0.25), 5.0)
	draw_arc(center, radius * 1.07 * orbit_scale, -_clock * spin_speed * 0.48, -_clock * spin_speed * 0.48 + TAU * 0.64, 72, metal, 2.0)
	draw_arc(center, radius * 1.07 * orbit_scale, _clock * spin_speed * 0.85, _clock * spin_speed * 0.85 + TAU * 0.14, 24, cyan, 3.0)
	if second_ring > 0.01:
		var ring_color := Color(0.70, 0.32, 0.15, 0.32 * second_ring)
		draw_arc(center, radius * 1.46 * orbit_scale, -_clock * spin_speed * 0.34, -_clock * spin_speed * 0.34 + TAU * 0.54, 72, ring_color, 2.0)
	if apex_progress > 0.01:
		var outer_color := Color(0.78, 0.38, 0.17, 0.42 * apex_progress)
		draw_arc(center, radius * (1.54 + apex_progress * 0.04) * orbit_scale, _clock * spin_speed * 0.2, _clock * spin_speed * 0.2 + TAU * 0.31, 48, outer_color, 2.0)
		draw_arc(center, radius * 1.50 * orbit_scale, -_clock * spin_speed * 0.16, -_clock * spin_speed * 0.16 + TAU * 0.18, 32, Color(0.31, 0.66, 0.61, 0.25 * apex_progress), 1.5)

	# Small orbiting energy markers move faster as production increases.
	var particle_count := 3 + roundi(node_progress * 3.0) + roundi(apex_progress * 2.0)
	for index in range(particle_count):
		var angle := _clock * spin_speed * (1.0 if index % 2 == 0 else -0.76) + TAU * float(index) / float(particle_count)
		var orbit := center + Vector2(cos(angle), sin(angle)) * radius * 1.22 * orbit_scale
		var marker_color := hot_orange if index != 1 else cyan
		var marker_alpha := 0.25 + node_progress * 0.75
		marker_color.a *= marker_alpha
		draw_circle(orbit, 3.0 + activity * 1.3 + bright_progress * 0.8 + apex_progress * 0.4, marker_color)
	if node_progress > 0.01:
		for index in range(4):
			var node_angle := _clock * spin_speed * (0.34 if index % 2 == 0 else -0.26) + TAU * float(index) / 4.0
			var node_position := center + Vector2(cos(node_angle), sin(node_angle)) * radius * 1.46 * orbit_scale
			var node_color := Color(1.0, 0.62, 0.28, 0.65 * node_progress)
			draw_circle(node_position, 3.2 + bright_progress * 0.8, node_color)

	# Layered warm light keeps orange as the primary energy signal.
	var burst_brightness := _prestige_burst * 0.10
	draw_circle(center, radius * 0.90 * pulse_scale, Color(0.72 + bright_progress * 0.08, 0.20 + bright_progress * 0.04, 0.045, 0.11 + activity * 0.055 + _pulse * 0.055 + bright_progress * 0.07 + burst_brightness))
	draw_circle(center, radius * 0.73 * pulse_scale, Color(0.95, 0.30 + bright_progress * 0.04, 0.075, 0.18 + activity * 0.065 + _pulse * 0.06 + bright_progress * 0.08 + burst_brightness))
	draw_circle(center, radius * 0.56 * pulse_scale, Color(0.99, 0.43 + bright_progress * 0.04, 0.13, 0.38 + bright_progress * 0.07 + burst_brightness))
	draw_circle(center, radius * 0.40 * pulse_scale, Color(1.0, 0.56 + bright_progress * 0.04, 0.23, 0.78 + burst_brightness))
	draw_circle(center, radius * 0.21 * pulse_scale, Color(1.0, 0.79 + bright_progress * 0.03, 0.48, 0.96))
	draw_arc(center, radius * 0.77 * pulse_scale, _clock * (0.42 + activity * 1.4), _clock * (0.42 + activity * 1.4) + TAU * 0.46, 56, Color(1.0, 0.57, 0.27, 0.75), 2.0)

	if not _multiplier_text.is_empty():
		var font := ThemeDB.fallback_font
		var text_width := maxf(size.x - 40.0, 120.0)
		draw_string(font, Vector2(20.0, center.y + radius * 1.66), _multiplier_text, HORIZONTAL_ALIGNMENT_CENTER, text_width, 14, Color(0.68, 0.68, 0.63))
