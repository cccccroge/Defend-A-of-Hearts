extends Node

var current_scene = null


func _ready():
	var current_scene_index = get_tree().get_root().get_child_count() - 1
	current_scene = get_tree().get_root().get_child(current_scene_index)


func goto_scene(path):
	# call the actual function after all objects in path is no longer used
	call_deferred("delayed_goto_scene", path)


func delayed_goto_scene(path):
	if current_scene:
		current_scene.free()
	var twoP_mode = load(path)
	current_scene = twoP_mode.instance()
	add_child(current_scene)
