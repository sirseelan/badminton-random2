extends CharacterBody2D

@export var player = 1

const SPEED = 300.0
const JUMP_VELOCITY = 300.0
const CUSTOM_GRAVITY = 400.0   # lower gravity for floatier jumps

# --- Tilt Settings ---
const MAX_TILT_GROUND = 0.3    # ~17° lean on ground
const MAX_TILT_AIR    = 0.05   # ~8° lean in air

const TILT_SPEED_GROUND = 0.5  # slower centering on ground
const TILT_SPEED_AIR    = 0.5  # softer following in air

const RETURN_DAMPING_GROUND = 1  # less damping = longer wobble
const RETURN_DAMPING_AIR    = 2.0  # no damping in air

const JUMP_WOBBLE = 0.07          # wobble impulse when jumping/landing

# --- State ---
var tilt_velocity: float = 0.0
var was_on_floor: bool = false
@onready var sprite2d: Sprite2D = $Player1

func _ready() -> void:
	if player == 2:
		sprite2d.flip_h = true
		sprite2d.position.x -= 4

func _physics_process(delta: float) -> void:
	# Apply custom gravity
	if not is_on_floor():
		velocity.y += CUSTOM_GRAVITY * delta

	# Jump only if on floor
	if player == 1:
		if Input.is_action_just_pressed("p1_jump") and is_on_floor():
			# Jump wobble follows movement/lean direction
			var dir = sign(velocity.x)
			if dir == 0: dir = sign(rotation)
			if dir == 0: dir = 1
			tilt_velocity += dir * JUMP_WOBBLE
			
			var direction = Vector2.UP.rotated(rotation)
			velocity.y = direction.y * JUMP_VELOCITY
			velocity.x += direction.x * JUMP_VELOCITY
	else:
		if Input.is_action_just_pressed("p2_jump") and is_on_floor():
			# Jump wobble follows movement/lean direction
			var dir = sign(velocity.x)
			if dir == 0: dir = sign(rotation)
			if dir == 0: dir = 1
			tilt_velocity += dir * JUMP_WOBBLE
			
			var direction = Vector2.UP.rotated(rotation)
			velocity.y = direction.y * JUMP_VELOCITY
			velocity.x += direction.x * JUMP_VELOCITY

		
		

	# Horizontal movement
	#var direction: float = Input.get_axis("ui_left", "ui_right")
	#if direction != 0.0:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Apply movement
	if is_on_floor():
		var damping = 0.05  # 0 < damping < 1
		velocity.x = lerp(velocity.x, 0.0, damping)
		
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
