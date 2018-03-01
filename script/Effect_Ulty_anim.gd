extends Node2D

signal should_gen_umbrella_left

func _ready():
	get_tree().set_pause(true)
	get_node("AnimationPlayer").play("brother_fade_in_out (copy)")
	get_node("AnimatedSprite").play("shooo")
	get_node("SamplePlayer").play("ultimate_sound")


func _on_AnimationPlayer_finished():
	print("animation finished!")
	get_tree().set_pause(false)
	emit_signal("should_gen_umbrella_left")
	queue_free()
