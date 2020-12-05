extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var jumpVel = 5.0
var walkingSpeed = 3.0

var PLAYER_GRAVITY = Vector3(0, -9.8, 0)
var targetBasis

var velocity = Vector3(0, 0, 0)

var rotationHelper
var camera

# Actually equivalent to Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED right now.
var inGame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rotationHelper = $RotationHelper
	camera = $RotationHelper/Camera
	targetBasis = self.transform.basis

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			inGame = false
	
	# Player walk direction in global space
	var walkingDir = Vector3()
	
	# Plane of player movement defined by basis of 
	var globalTransform = rotationHelper.get_global_transform()
	
	# (x,y) coordinates in player movement plane
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
		
	# DEBUG ACTION
	if Input.is_action_just_pressed("debug"):
		var oldGravity = PLAYER_GRAVITY
		PLAYER_GRAVITY = Vector3(9.8, 0, 0)
		
		# Assume oldGravity and newGravity DO NOT POINT IN THE SAME DIRECTION
		var rotAxis = oldGravity.cross(PLAYER_GRAVITY).normalized()
		var rotAngle = acos(oldGravity.normalized().dot(PLAYER_GRAVITY.normalized()))

		# Rotate basis
		targetBasis = transform.basis.rotated(rotAxis, rotAngle)

	# TODO: THIS IS NOT FRAMERATE INDEPENDENT, PLEASE FIX BEFORE RELEASE
	transform.basis = transform.basis.slerp(targetBasis, 10 * delta)

	input_movement_vector = input_movement_vector.normalized()
	
	# Transform (x,y) player movement plane into global space
	walkingDir -= globalTransform.basis.z * input_movement_vector.y
	walkingDir += globalTransform.basis.x * input_movement_vector.x
	# walkingDir should be normalized still
	
	print(str("Basis vectors: ", globalTransform.basis.z, ", ", globalTransform.basis.x))
	print(walkingDir)
	
	# Project walking direction onto the plane perpendicular to gravity
	var up = -PLAYER_GRAVITY.normalized()
	walkingDir -= up.dot(walkingDir) * up
	walkingDir = walkingDir.normalized()

	var target = walkingSpeed * walkingDir
	# target is perpendicular to gravity

	# Set velocity into walking dir, but leave component along gravity untouched.
	velocity = velocity.dot(up) * up + target
	velocity += PLAYER_GRAVITY * delta

	if is_on_floor():
		if Input.is_action_just_pressed('movement_jump'):
			velocity = up * jumpVel + (velocity - velocity.dot(up) * up)
	
	velocity = move_and_slide(velocity, up)
	
	var push = 10
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * push)

func _input(event):
	var sensitivity = 0.001
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			inGame = true
	elif event is InputEventMouseMotion:
		if inGame:
			camera.rotate_x(-event.relative.y * sensitivity)
			rotationHelper.rotate_y(-event.relative.x * sensitivity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
