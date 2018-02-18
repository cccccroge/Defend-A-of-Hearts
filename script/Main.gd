extends Node

func _ready():
	get_node("/root/LoadScene").goto_scene("res://scene/Startup_page.tscn")
