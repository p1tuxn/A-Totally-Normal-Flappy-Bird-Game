extends CharacterBody2D

const Gravity: int = 1000
const Max_vel: int = 600
const flap_speed: int = -500
var flying: bool = false
var falling: bool = false
const Start_pos = Vector2(400, 600)

func _ready() -> void:
	reset()

func reset():
	falling = false
	flying = false
	position = Start_pos
	set_rotation(0)

func _physics_process(delta: float) -> void:
	if flying or falling:
		velocity.y += Gravity * delta
		
		if velocity.y > Max_vel:
			velocity.y = Max_vel
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
		elif falling:
			set_rotation(PI/2)
		move_and_collide(velocity * delta)
		
func flap():
	velocity.y = flap_speed
