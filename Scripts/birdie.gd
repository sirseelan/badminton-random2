extends RigidBody2D

const CUSTOM_GRAVITY = 400
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += CUSTOM_GRAVITY * delta
