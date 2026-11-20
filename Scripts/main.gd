extends Node2D

@export var building_scene: PackedScene

var game_running: bool
var game_over: bool
var scroll
var score
const scroll_speed: int = 4
var screen_size: Vector2i
var ground_height: int
var pipes: Array
const pipe_delay: int = 100
const pipe_range: int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	ground_height = $Ground.get_node("CollisionShape2D").shape.size.y
	screen_size = get_window().size


func new_game():
	game_running = false
	game_over = false
	score = 0
	$ScoreLabel.text = str(score)
	pipes.clear()
	generate_pipe()
	scroll = 0
	$Plane.reset()

func _input(event: InputEvent) -> void:
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Plane.flying:
						$Plane.flap()
						check_top()

func start_game():
	game_running = true
	$Plane.flying = true 
	$Plane.flap()
	$BuildingTimer.start()

func stop_game():
	$BuildingTimer.stop()
	$Plane.flying = false
	game_running = false
	game_over = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		scroll += scroll_speed
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		
		for building in pipes:
			building.position.x -= scroll_speed


func _on_building_timer_timeout() -> void:
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

func check_top():
	if $Plane.position.y < 0:
		$Plane.falling = false
		stop_game()

func plane_hit():
	stop_game()

func _on_ground_hit() -> void:
	$Plane.falling = false 
	stop_game()
