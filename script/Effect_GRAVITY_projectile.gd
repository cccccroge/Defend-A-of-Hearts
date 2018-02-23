extends Node2D

# inspector var
export(float) var damping
export(float) var velocity_factor

# nodes
onready var rigidBody = get_node("Projectile")
onready var particles = rigidBody.get_node("Smoke")

# signals
signal gen_gravity_hole(hole)

# variable
var owner	# 1 means player 1...


func _ready():
	rigidBody.set_linear_damp(damping)
	particles.set_emitting(true)


func init(your_owner):
	owner = your_owner


func _on_Projectile_sleeping_state_changed():
	if rigidBody.is_sleeping():
		# add hole effect
		var hole = load("res://scene/character/Effect_GRAVITY.tscn").instance()
		hole.init(owner)
		hole.set_as_toplevel(true)
		hole.set_pos(rigidBody.get_pos())
		get_parent().add_child(hole)
		queue_free()
		# play sound
		var sample_player = SamplePlayer.new()
		var sample_library = SampleLibrary.new()
		var sample_all_in_my_control = load("res://sound/all_in_my_controlwav.wav")
		sample_library.add_sample("all_in_my_control", sample_all_in_my_control)
		sample_player.set_sample_library(sample_library)
		sample_player.play("all_in_my_control", false)
