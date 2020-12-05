extends RigidBody
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (float) var speed = 15
var exploded = false
var local_collision_norm
var last_update_velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var dir = transform.basis
	set_axis_velocity(Vector3(dir.z * speed))
	
	var color =  Color(randf(), randf(), randf())
	
	var material = $BallMeshInstance.get_surface_material(0).duplicate()
	material.albedo_color = color
	$BallMeshInstance.set_surface_material(0,material)
	$BallMeshInstance.mesh.surface_set_material(0,material)

	var processMat = $Particles.process_material.duplicate()
	processMat.color = color
	$Particles.process_material = processMat

	pass # Replace with function body.

func _physics_process(delta):
	last_update_velocity = linear_velocity

func _integrate_forces( state ):
	# Get Normal
	if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
		local_collision_norm = state.get_contact_local_normal(0)
		# Get velocity direction
		#state.get_contact_collider_velocity_at_position(0)

func _on_Paintball_body_entered(body):
	# Get Reflect from collision_normal and collision_velocity before that collision
	var n_collision_velocity = last_update_velocity
	var n_collision_norm = local_collision_norm.normalized() * 2
	print("vel = " 		+ String(n_collision_velocity))
													#r=d−2(d⋅n)n
	var reflectDir = n_collision_velocity - 2*(n_collision_velocity.dot(n_collision_norm)) * n_collision_norm

	# Particle emitting to Reflect direction
	$Particles.process_material.direction = reflectDir;
	$Particles.set_emitting(true)
	sleeping = true
	KillAfterTime($Particles.lifetime)
	$CollisionShape.queue_free()
	$BallMeshInstance.queue_free()
		
	pass # Replace with function body.

func KillAfterTime(time: float):
	var t = Timer.new()
	t.set_wait_time(time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	queue_free()
	pass
