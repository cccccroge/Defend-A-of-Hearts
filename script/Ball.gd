extends RigidBody2D

# nodes
onready var tween = get_node("Tween")
onready var collision_shape = get_node("CollisionShape2D")

# properties
export(float) var MASS
export(float) var BOUNCITY
export(float) var FRICTION
var circle_shape
var reset_side

# outside variables
var table_w
var table_h


func _ready():
	set_mass(MASS)
	set_bounce(BOUNCITY)
	set_linear_damp(FRICTION)
	circle_shape = get_shape(0)
	reset_side = -1
	table_w = get_viewport_rect().size.x
	table_h = get_viewport_rect().size.y - 100
	
	hide()


func random_reset():
	var randomNum = randi() % 2 + 1
	reset(randomNum)


func reset(who_got_hit):
	if who_got_hit == 1:
		set_pos(Vector2(table_w / 2 - 120, table_h / 2))
	elif who_got_hit == 2:
		set_pos(Vector2(table_w / 2 + 120, table_h / 2))
	set_linear_velocity(Vector2(0, 0))
	set_angular_velocity(0)
	get_node("Sprite").set_self_opacity(1.0)
	enable_collision_shape(true)
	show()


func disappear_anim():
	var tween = Tween.new()
	tween.set_name("Tween")
	tween.interpolate_property(get_node("Sprite"), "visibility/self_opacity",
			1, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "_on_Tween_tween_complete")
	
	add_child(tween)
	tween.start()


func _on_Tween_tween_complete( object, key):
	var wait_timer = Timer.new()
	wait_timer.set_name("wait_timer")
	wait_timer.set_wait_time(0.75)
	wait_timer.set_one_shot(true)
	wait_timer.connect("timeout", self, "_on_wait_timer_timeout")
	
	add_child(wait_timer)
	wait_timer.start()


func _on_wait_timer_timeout():
	get_node("wait_timer").queue_free()
	reset(reset_side)


func enable_collision_shape(boolean):
	if boolean == false:
		remove_shape(0)
	else:
		if get_shape_count() == 0:
			add_shape(circle_shape)


func set_reset_side(side):
	reset_side = side
