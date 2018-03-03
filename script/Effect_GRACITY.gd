extends Node2D
signal hole_finished
signal ball_got_sucked_by_p1
signal ball_got_sucked_by_p2

# nodes
onready var animation = get_node("effect_anim")
onready var absorb_area = get_node("Absorb_area")
onready var disappear_area = get_node("Disappear_area")
onready var stream_player = get_node("StreamPlayer")
onready var tween = get_node("Tween")

# variables
export(int) var duration
export(int) var gravity

enum ANIM_STATE { SHOW_UP, IDLE, FADE }
var anim_state
var shape_absorb
var shape_disappear
var shape_absorb_default_radius
var shape_disappear_default_radius
var owner


func _ready():
	# setup gravity
	absorb_area.set_gravity(gravity)
	
	# make shape unique
	shape_absorb_default_radius = absorb_area.get_node("CollisionShape2D").get_shape().get_radius()
	shape_disappear_default_radius = disappear_area.get_node("CollisionShape2D").get_shape().get_radius()
	
	shape_absorb = CircleShape2D.new()
	shape_absorb.set_radius(shape_absorb_default_radius)
	absorb_area.get_node("CollisionShape2D").set_shape(shape_absorb)
	
	shape_disappear = CircleShape2D.new()
	shape_disappear.set_radius(shape_disappear_default_radius)
	disappear_area.get_node("CollisionShape2D").set_shape(shape_disappear)
	
	# play first animation
	animation.play("show_up")
	anim_state = ANIM_STATE.SHOW_UP
	get_node("fade_timer").set_wait_time(duration)
	
	# check if the ball is already inside
	#var ball_group = get_tree().get_nodes_in_group("can_score")
	#for b in ball_group:
		#if absorb_area.overlaps_body(b):
			#b.set_can_sleep(false)
	
	# set fade stream
	tween.interpolate_property(stream_player, "stream/volume_db", 
			0, -80, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	# signal
	connect("hole_finished", get_parent(), "_on_player_hole_finished")

func init(your_owner):
	owner = your_owner


func _on_effect_anim_finished():
	if anim_state == ANIM_STATE.SHOW_UP:
		animation.play("idle")
		anim_state = ANIM_STATE.IDLE
		get_node("fade_timer").start()
	elif anim_state == ANIM_STATE.IDLE:
		animation.play("idle")
	elif anim_state == ANIM_STATE.FADE:
		emit_signal("hole_finished")
		queue_free()


func _on_fade_timer_timeout():
	animation.play("fade")
	anim_state = ANIM_STATE.FADE
	disable_absorbtion()


func _on_Disappear_area_body_enter( body ):
	if body.is_in_group("can_score"):
		# disable functionality
		get_node("fade_timer").stop()
		disable_absorbtion()
		body.set_linear_velocity(Vector2(0, 0))
		
		# make ball and effect both disappeared
		body.disappear_anim()
		body.enable_collision_shape(false)
		body.set_reset_side(owner)
		
		animation.play("fade")
		anim_state = ANIM_STATE.FADE
		
		# fade out stream
		tween.start()
		
		# add ulty
		if owner == 1:
			emit_signal("ball_got_sucked_by_p1")
		elif owner == 2:
			emit_signal("ball_got_sucked_by_p2")


func disable_absorbtion():
	absorb_area.queue_free()
	disappear_area.queue_free()


func scaling_area(scale):
	shape_absorb.set_radius(shape_absorb_default_radius * scale)
	absorb_area.set_shape(0, shape_absorb)
	#absorb_area.get_node("CollisionShape2D").set_shape(shape_absorb)
	
	shape_disappear.set_radius(shape_disappear_default_radius * scale)
	disappear_area.set_shape(0, shape_disappear)
	#disappear_area.get_node("CollisionShape2D").set_shape(shape_disappear)
