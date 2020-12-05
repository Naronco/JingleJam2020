extends Spatial

var materials = [
	preload("res://PaintBall/ParticleMaterial.tres"),
]

var meshMaterials = [
	preload("res://PaintBall/ParticleMeshMaterial.tres"),
]

func _ready():
	for material in materials:
		var particles_instance = Particles.new()
		particles_instance.set_process_material(material)
		particles_instance.set_one_shot(true)
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)

	var mesh = $MeshInstance.mesh

	for material in meshMaterials:
		var particles_instance = Particles.new()
		particles_instance.set_process_material(materials[0])
		particles_instance.set_one_shot(true)
		particles_instance.set_emitting(true)
		particles_instance.draw_pass_1 = mesh
		mesh.surface_set_material(0, material)
		self.add_child(particles_instance)


var cached = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cached:
		visible = false
		set_process(false)
		
	cached = true
