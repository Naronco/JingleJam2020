tool
extends "res://addons/color_grading_lut/filter_node/color_grading_filter.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (float, -1.0, 1.0) var temperature
export (StreamTexture) var cold_lut
export (StreamTexture) var warm_lut

# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	cold_lut = load("res://color_luts/cold.png")
	warm_lut = load("res://color_luts/hot.png")
	
	material.shader = load("res://color_luts/color_effects.shader")
	_draw()

func _draw():
	._draw()
	material.set_shader_param("temperature", temperature)
	material.set_shader_param("cold_lut", cold_lut)
	material.set_shader_param("warm_lut", warm_lut)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
