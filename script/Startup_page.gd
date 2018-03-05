extends Node2D

onready var streamPlayer = get_node("/root/Background_music_transition")
onready var instruction_page = get_node("CenterContainer/Instruction")
onready var player = get_node("SamplePlayer")

func _ready():
	streamPlayer.play("res://sound/Silent Partner - 7th Floor Tango - Cinematic  Romantic.ogg")
	instruction_page.hide()
	set_process_input(true)


func _input(event):
	if event.type == InputEvent.KEY:
		instruction_page.hide()


func play_di():
	player.play("di", true)


func play_da():
	player.play("da", true)


func _on_PlayButton_pressed():
	# fade out music
	streamPlayer.fade_out(3.0)
	
	# switch to play scene
	get_node("/root/LoadScene").goto_scene("res://scene/2P_mode.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_OptionButton_pressed():
	instruction_page.show()


func _on_PlayButton_mouse_enter():
	play_di()


func _on_OptionButton_mouse_enter():
	play_di()


func _on_ExitButton_mouse_enter():
	play_di()
