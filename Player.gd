extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var jumpVel = 5.0
export(float) var walkingSpeed = 6.0
export(float) var mouseSensitivity = 0.002

var PLAYER_GRAVITY = Vector3(0, -9.8, 0)

var SLERP_TIME = 0.5 # in seconds
var lastBasis
var basisSlerping = false
var basisSlerpTime = 0.0 # in seconds
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

# new_gravity IS NOT parallel to old_gravity
func _change_gravity(new_gravity):
	if basisSlerping:
		pass
	
	var oldGravity = PLAYER_GRAVITY
	PLAYER_GRAVITY = new_gravity
	
	# TODO Use physics server gravity also for player.
	PhysicsServer.area_set_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, PLAYER_GRAVITY)
	
	# Assume oldGravity and newGravity DO NOT POINT IN THE SAME DIRECTION
	var rotAxis = oldGravity.cross(PLAYER_GRAVITY).normalized()
	var rotAngle = acos(oldGravity.normalized().dot(PLAYER_GRAVITY.normalized()))

	# Rotate basis
	lastBasis = transform.basis
	targetBasis = transform.basis.rotated(rotAxis, rotAngle)
	basisSlerping = true
	basisSlerpTime = 0.0

# g -> -g
func _flip_gravity():
	if basisSlerping:
		pass

	var oldGravity = PLAYER_GRAVITY
	PLAYER_GRAVITY = -PLAYER_GRAVITY
	
	# TODO Use physics server gravity also for player.
	PhysicsServer.area_set_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, PLAYER_GRAVITY)
	
	# In this case, the cross product of old_gravity and new_gravity is zero, so we have to (arbitrarily) pick an axis of rotation and rotate about 180 deg
	# Choose some perpendicular axis (This method should be stable but rather random)
	var up = PLAYER_GRAVITY.normalized()
	var rotAxis = Vector3(up.y, -up.x, 0) if up.z < up.x else Vector3(0, -up.z, up.y)
	var rotAngle = PI
	
	lastBasis = transform.basis
	targetBasis = transform.basis.rotated(rotAxis, rotAngle)
	basisSlerping = true
	basisSlerpTime = 0.0

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
	if not basisSlerping and Input.is_action_just_pressed("debug"):
		_flip_gravity()

	if basisSlerping:
		basisSlerpTime += delta
		if basisSlerpTime >= SLERP_TIME:
			basisSlerpTime = SLERP_TIME
			basisSlerping = false

		transform.basis = lastBasis.slerp(targetBasis, basisSlerpTime / SLERP_TIME)

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
	
	var push = 0.1
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.has_method("apply_central_impulse"):
			print("Pushing")
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push)

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			inGame = true
	elif event is InputEventMouseMotion:
		if inGame:
			camera.rotate_x(-event.relative.y * mouseSensitivity)
			rotationHelper.rotate_y(-event.relative.x * mouseSensitivity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
