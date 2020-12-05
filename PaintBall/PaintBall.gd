extends RigidBody
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (float) var speed = 15
var exploded = false

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

func _on_Paintball_body_entered(body):
	if(body.has_node("crate")):
		$Particles.set_emitting(true)
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
