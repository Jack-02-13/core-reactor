extends Control

const PARTICLE_COUNT := 22

var _clock := 0.0
var _positions: Array[Vector2] = []
var _speeds: Array[float] = []
var _radii: Array[float] = []
var _alphas: Array[float] = []
var _cyan_particles: Array[bool] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 739104
	var viewport_size := get_viewport_rect().size
	for index in range(PARTICLE_COUNT):
		_positions.append(Vector2(rng.randf_range(0.0, viewport_size.x), rng.randf_range(0.0, viewport_size.y)))
		_speeds.append(rng.randf_range(3.0, 8.0))
		_radii.append(rng.randf_range(0.8, 1.7))
		_alphas.append(rng.randf_range(0.018, 0.045))
		_cyan_particles.append(index % 7 == 0)
	set_process(true)

func _process(delta: float) -> void:
	_clock += delta
	var viewport_size := size
	for index in range(_positions.size()):
		var point := _positions[index]
		point.y -= _speeds[index] * delta
		point.x += sin(_clock * 0.18 + float(index) * 1.9) * delta * 1.1
		if point.y < -4.0:
			point.y = viewport_size.y + 4.0
			point.x = fposmod(point.x + float(index * 37), maxf(viewport_size.x, 1.0))
		_positions[index] = point
	queue_redraw()

func _draw() -> void:
	var shimmer := 0.5 + 0.5 * sin(_clock * 0.12)
	var line_y := size.y * 0.28 + sin(_clock * 0.07) * size.y * 0.025
	draw_line(Vector2(0.0, line_y), Vector2(size.x, line_y), Color(0.89, 0.39, 0.17, 0.008 + shimmer * 0.008), 1.0)
	var lower_y := size.y * 0.76 + sin(_clock * 0.055 + 1.4) * size.y * 0.018
	draw_line(Vector2(0.0, lower_y), Vector2(size.x, lower_y), Color(0.25, 0.57, 0.53, 0.006 + shimmer * 0.006), 1.0)
	for index in range(_positions.size()):
		var color := Color(0.95, 0.48, 0.23, _alphas[index])
		if _cyan_particles[index]:
			color = Color(0.32, 0.70, 0.65, _alphas[index] * 0.72)
		draw_circle(_positions[index], _radii[index], color)
