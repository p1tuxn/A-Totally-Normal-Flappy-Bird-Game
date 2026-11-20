extends Node2D

@export var building_scene: PackedScene
@export var BOOM: PackedScene

var game_running: bool = false
var game_over: bool = false
var scroll: float = 0.0
var score: int = 0
var screen_size: Vector2i
var ground_height: int
var pipes: Array = []

const scroll_speed: int = 240
const parallax_speeds: Array[float] = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0]
const pipe_delay: int = 100
const pipe_range: int = 200


func _ready() -> void:
	ground_height = $Ground.get_node("CollisionShape2D").shape.size.y
	screen_size = Vector2i(get_viewport_rect().size)
	new_game()


func new_game():
	game_running = false
	game_over = false
	score = 0
	$ScoreLabel.text = str(score)
	for building in pipes:
		building.queue_free()
	pipes.clear()
	generate_pipe()
	scroll = 0
	_reset_parallax()
	$Plane.reset()

func _reset_parallax() -> void:
	for i in range(parallax_speeds.size()):
		var layer: Parallax2D = $Background.get_child(i)
		layer.autoscroll = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if game_over:
				new_game()
			elif not game_running:
				start_game()
			elif $Plane.flying:
				$Plane.flap()

func start_game():
	game_running = true
	$Plane.flying = true 
	$Plane.flap()
	$BuildingTimer.start()
	set_parallax_speed(1.0)

func stop_game():
	$BuildingTimer.stop()
	$Plane.flying = false
	game_running = false
	game_over = true
	set_parallax_speed()

func set_parallax_speed(speed: float = 0.0):
	for i in range(parallax_speeds.size()):
		var layer: Parallax2D = $Background.get_child(i)
		layer.autoscroll = Vector2(-parallax_speeds[i] * speed, 0)


func _process(delta: float) -> void:
	if not game_running:
		return
	
	if $Plane.position.y < 0:
		$Plane.falling = true
		stop_game()
		return
		
	scroll += scroll_speed * delta
	
	if scroll >= screen_size.x:
		scroll = 0
	$Ground.position.x = -scroll

	for i in range(pipes.size() - 1, -1, -1):
		var building = pipes[i]
		building.position.x -= scroll_speed * delta
		if building.position.x < -building.get_node("CollisionShape2D").shape.size.x:
			pipes.remove_at(i)
			building.queue_free()


func _on_building_timer_timeout() -> void:
	if game_running:
		generate_pipe()

func generate_pipe():
	var building = building_scene.instantiate()
	building.position.x = screen_size.x + pipe_delay
	building.position.y = (screen_size.y - ground_height) / 2 + randi_range(-pipe_range, pipe_range)
	building.hit.connect(plane_hit)
	building.scored.connect(scored)
	add_child(building)
	pipes.append(building)

func scored():
	score += 1 
	$ScoreLabel.text = str(score)

func plane_hit():
	var tween = create_tween()
	tween.tween_property($ScoreLabel, "theme_override_font_sizes/font_size", 60, 1)
	$ScoreLabel.text = "wallah you are a fine pilot\nOsama Approves"
	$Plane.falling = false
	stop_game()
	boom()

func _on_ground_hit() -> void:
	var tween = create_tween()
	tween.tween_property($ScoreLabel, "theme_override_font_sizes/font_size", 60, 1)
	$ScoreLabel.text = "wallah you are a shit pilot\nOsama does not Approve"
	$Plane.falling = true
	stop_game()
	boom()

func boom():
	var boom = BOOM.instantiate()
	add_child(boom)
	boom.global_position = $Plane.global_position
