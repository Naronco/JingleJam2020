extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var damage = 1.0
export(Vector3) var velocity = Vector3()
export(float) var vanishTime = 10.0 # in s

var timeSinceSpawn = 0.0 # in s

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(body):
	if body.get_name() == "Player":
		body.do_damage(self, damage)
		var knockbackDir = body.global_transform.origin - global_transform.origin
		knockbackDir.y = 0
		if knockbackDir.length_squared() > 0.01:
			body.knockback(knockbackDir.normalized() * 20)
	
	# Play snowball destroy anim
	queue_free()

func _physics_process(delta):
	var gravityDir = PhysicsServer.area_get_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY_VECTOR)
	var gravityStrength = PhysicsServer.area_get_param(get_world().get_space(), PhysicsServer.AREA_PARAM_GRAVITY)

	velocity += gravityDir * gravityStrength * delta

	transform.origin += delta * velocity
	
	timeSinceSpawn += delta
	if timeSinceSpawn >= vanishTime:
		queue_free()
