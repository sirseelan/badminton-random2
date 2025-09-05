extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -200.0
const CUSTOM_GRAVITY = 400.0   # lower gravity for floatier jumps

# --- Tilt Settings ---
const MAX_TILT_GROUND = 0.3    # ~17° lean on ground
const MAX_TILT_AIR    = 0.25   # ~8° lean in air

const TILT_SPEED_GROUND = 1.5  # slower centering on ground
const TILT_SPEED_AIR    = 0.5  # softer following in air

const RETURN_DAMPING_GROUND = 3.0  # less damping = longer wobble
const RETURN_DAMPING_AIR    = 2.0  # no damping in air

const JUMP_WOBBLE = 0.15          # wobble impulse when jumping/landing

# --- State ---
var tilt_velocity: float = 0.0
var was_on_floor: bool = false

func _physics_process(delta: float) -> void:
	# Apply custom gravity
	if not is_on_floor():
		velocity.y += CUSTOM_GRAVITY * delta

	# Jump only if on floor
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		# Jump wobble follows movement/lean direction
		var dir = sign(velocity.x)
		if dir == 0: dir = sign(rotation)
		if dir == 0: dir = 1
		tilt_velocity += dir * JUMP_WOBBLE
		
		var x_component = cos(rotation)
		var y_component = sin(rotation)
		velocity.y = JUMP_VELOCITY
		
		

	# Horizontal movement
	var direction: float = Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Apply movement
	move_and_slide()

	# Landing wobble
	if not was_on_floor and is_on_floor():
		var dir = sign(velocity.x)
		if dir == 0: dir = sign(rotation)
		if dir == 0: dir = sign(tilt_velocity)
		if dir == 0: dir = 1
		tilt_velocity += dir * JUMP_WOBBLE

	was_on_floor = is_on_floor()

	# --- Rotation with ground/air differences ---
	var max_tilt: float
	var tilt_speed: float
	var return_damping: float

	if is_on_floor():
		max_tilt = MAX_TILT_GROUND
		tilt_speed = TILT_SPEED_GROUND
		return_damping = RETURN_DAMPING_GROUND
	else:
		max_tilt = MAX_TILT_AIR
		tilt_speed = TILT_SPEED_AIR
		return_damping = RETURN_DAMPING_AIR

	var target_rotation: float = clamp(velocity.x / SPEED, -1.0, 1.0) * max_tilt
	var diff: float = target_rotation - rotation

	tilt_velocity += diff * tilt_speed * delta
	tilt_velocity -= tilt_velocity * return_damping * delta
	rotation += tilt_velocity
