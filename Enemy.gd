extends KinematicBody


var velocity = Vector3()

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var gravityDir = PhysicsServer.area_get_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR)
	var gravityStrength = PhysicsServer.area_get_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY)

	var up = -gravityDir.normalized()
	var velUp = velocity.dot(up) * up
	var velPlane = velocity - velUp

	var floorFrictionCoeff = 2

	velocity += floorFrictionCoeff * -velPlane * delta
	velocity += gravityDir * gravityStrength * delta

	velocity = move_and_slide(velocity, up)
	

func set_player(p):
	player = p
