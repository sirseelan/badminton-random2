extends RigidBody2D

var override_time: float = 0.0
var forced_spin: float = 0.0  # radians/sec
@onready var parent_node = get_parent()

var shot_type = 0

func _physics_process(delta: float) -> void:
	var angle_deg = rad_to_deg(global_rotation)
	# Start override when pressing Right Arrow
	if Input.is_action_just_pressed("ui_right"):
		override_time = 0.8
		if parent_node.is_on_floor():
			forced_spin = -15.0
			shot_type = 1
		else:
			forced_spin = 15.0  # constant spin (radians/sec). Try negative for opposite direction.
			shot_type = 2

	# While override is active, force angular velocity
	if override_time > 0.0:
		angular_velocity = forced_spin
		override_time -= delta
	else:
		if (angle_deg > 40 or angle_deg <-40):
			angular_velocity = -angular_velocity
	if override_time < 0.1:
		if shot_type == 1:
			forced_spin = -50.0
		elif shot_type == 2:
			forced_spin = 50.0
	
	
