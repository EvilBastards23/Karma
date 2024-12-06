extends Camera2D
# add this script to camere if you want to dramatic camera movement



# Dramatic movement parameters
@export_group("Movement Intensity")
@export var max_offset: float = 200.0  # Maximum camera displacement
@export var movement_intensity: float = 3.0  # Overall movement multiplier
@export var rotation_intensity: float = 5.0  # How much the camera can rotate

# Mouse influence parameters
@export_group("Mouse Influence")
@export var mouse_multiplier: float = 1.5  # Amplify mouse movement
@export var mouse_acceleration: float = 5.0  # How quickly camera responds to mouse
@export var mouse_damping: float = 0.1  # Dampens rapid mouse velocity changes

# Noise parameters for organic movement
@export_group("Noise Movement")
@export var noise_scale: float = 0.1  # Scale of noise movement
@export var noise_speed: float = 1.0  # Speed of noise movement

# Parallax Layer parameters


# Internal tracking variables
var base_position: Vector2
var noise_time: float = 0.0
var target_offset: Vector2
var smooth_target_offset: Vector2 = Vector2.ZERO
var last_mouse_pos: Vector2
var mouse_velocity: Vector2 = Vector2.ZERO

func _ready():
	base_position = global_position
	last_mouse_pos = get_global_mouse_position()
	target_offset = Vector2.ZERO


	

func _process(delta):
	# Update noise time for organic movement
	noise_time += delta * noise_speed

	# Calculate mouse movement and velocity
	var current_mouse_pos = get_global_mouse_position()
	var raw_mouse_velocity = current_mouse_pos - last_mouse_pos
	mouse_velocity = lerp(mouse_velocity, raw_mouse_velocity, mouse_damping)
	last_mouse_pos = current_mouse_pos

	# Calculate mouse offset
	var mouse_offset = mouse_velocity * mouse_multiplier

	# Apply noise movement (smooth using sin or cos for organic motion)
	var noise_offset = Vector2(
		noise_scale * sin(noise_time),
		noise_scale * cos(noise_time)
	) * movement_intensity

	# Calculate final target offset
	target_offset = mouse_offset + noise_offset

	# Clamp the offset to the max limit
	if target_offset.length() > max_offset:
		target_offset = target_offset.normalized() * max_offset

	# Smooth the target offset for less jitter
	smooth_target_offset = lerp(smooth_target_offset, target_offset, delta * mouse_acceleration)

	# Smoothly update global position
	global_position = lerp(global_position, base_position + smooth_target_offset, delta * mouse_acceleration)

	# Add dramatic rotation based on offset
	rotation = lerp_angle(
		rotation,
		smooth_target_offset.x * 0.0001 * rotation_intensity,
		delta * 2.0
	)
	
