extends ParallaxBackground

const parallax_speeds: Array[float] = [8.0, 14.0, 20.0, 28.0, 38.0, 50.0]
const parallax_start_offset := Vector2(632, 464)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(parallax_speeds.size()):
		var layer: Parallax2D = $ParallaxBackground.get_child(i)
		layer.scroll_offset.x -= parallax_speeds[i] * delta
