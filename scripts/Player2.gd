extends CharacterBody3D

@export var speed: float = 10.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var model: Node3D = $Rig

@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D

var camera_x_rotation: float = 0.0
var is_crouching: bool = false
var is_jumping: bool = false
var current_speed: float = 5.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_speed = walk_speed


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

	# Toggle crouching
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching


func _physics_process(delta):
	var movement_vector = Vector3.ZERO

	# Handle movement input
	if Input.is_action_pressed("movement_backward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_forward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_right"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_left"):
		movement_vector += head.basis.x

	movement_vector = movement_vector.normalized()

	# Toggle running
	if Input.is_action_pressed("run"):
		current_speed = run_speed
	else:
		current_speed = walk_speed

	# Apply movement
	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if is_jumping and velocity.y <= 0:
			is_jumping = false

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		anim_player.play("Jump")
		velocity.y = jump_power
		is_jumping = true

	# Move the character
	move_and_slide()

	# Handle animations
	if is_jumping:
		pass
	else:
		if movement_vector != Vector3.ZERO:
			var movement_direction = Vector3(movement_vector.x, 0, movement_vector.z).normalized()
			model.global_transform.basis = Basis.looking_at(movement_direction, Vector3.UP).rotated(
				Vector3.UP, deg_to_rad(180)
			)

			# Play appropriate animation
			if is_crouching:
				anim_player.play("Crouch_Fwd")
			else:
				if current_speed == run_speed:
					anim_player.play("Jog_Fwd", -1, 1.5)
				else:
					anim_player.play("Jog_Fwd")
		else:
			if is_crouching:
				anim_player.play("Crouch_Idle")
			else:
				anim_player.play("Idle")
