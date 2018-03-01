extends RigidBody2D

onready var animation = get_node("AnimatedSprite")
onready var timer_anim_interval = get_node("Interval_timer")
onready var collider = get_node("CollisionPolygon2D")
onready var timer_to_move = get_node("To_move_timer")
onready var player = get_node("SamplePlayer")

export(int) var SPEED
export(int) var Y_OFFSET
export(int) var VIBRATE_RATE

var direction
var initial_y

func _ready():
	collider.set_trigger(true)
	activate()
	direction = 1
	initial_y = get_pos().y


func activate():
	animation.play("rotate")
	


func _on_AnimatedSprite_finished():
	if animation.get_animation() == "rotate":
		timer_anim_interval.start()
	elif animation.get_animation() == "pop_up":
		collider.set_trigger(false)
		timer_to_move.start()


func _on_Interval_timer_timeout():
	animation.play("pop_up")


func _on_To_move_timer_timeout():
	animation.play("shooo")
	player.play("umbrella_wooshes")
	set_fixed_process(true)


func _fixed_process(delta):
	var new_x = get_pos().x - SPEED * delta
	var new_y = get_pos().y + direction * VIBRATE_RATE * delta
	
	if direction == 1 and get_pos().y > initial_y + Y_OFFSET:
		direction = -direction
	if direction == -1 and get_pos().y < initial_y - Y_OFFSET:
		direction = -direction
	
	set_pos(Vector2(new_x, new_y))
	if get_pos().x < -180:
		queue_free()
