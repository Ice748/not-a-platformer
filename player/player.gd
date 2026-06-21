extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.02

var isFallAnimation = false

@onready var player = $Body
@onready var camera_root_out = $CameraRootOut
@onready var camera_root_in = $CameraRootOut/CameraRootIn

@onready var animation_player = $AnimationPlayer


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_root_out.rotate_y(-event.relative.x * SENSITIVITY)
		camera_root_in.rotate_x(-event.relative.y * SENSITIVITY)
		camera_root_in.rotation.x = clamp(camera_root_in.rotation.x, deg_to_rad(-90), deg_to_rad(30))


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (camera_root_out.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		player.rotation.y = camera_root_out.rotation.y
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if direction == Vector3.ZERO and is_on_floor():
		isFallAnimation = false
		if animation_player.current_animation != "Idle":
			animation_player.stop()
			animation_player.play("Idle")
	elif direction != Vector3.ZERO and is_on_floor():
		isFallAnimation = false
		if animation_player.current_animation != "Walk":
			animation_player.stop()
			animation_player.play("Walk")
	elif not is_on_floor():
		if animation_player.current_animation != "Fall" and not isFallAnimation:
			isFallAnimation = true
			animation_player.stop()
			animation_player.play("Fall")

	move_and_slide()
