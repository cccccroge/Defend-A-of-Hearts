extends Node2D

onready var streamPlayer = get_node("/root/Background_music_transition")

func _ready():
	streamPlayer.play("res://sound/Silent Partner - 7th Floor Tango - Cinematic  Romantic.ogg")


func _on_PlayButton_pressed():
	# fade out music
	streamPlayer.fade_out(3.0)
	
	# switch to play scene
	get_node("/root/LoadScene").goto_scene("res://scene/2P_mode.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()
