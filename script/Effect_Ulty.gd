extends RigidBody2D

onready var animation = get_node("AnimatedSprite")
onready var timer_anim_interval = get_node("Interval_timer")
onready var collider = get_node("CollisionPolygon2D")
onready var timer_to_move = get_node("To_move_timer")

export(int) var SPEED

func _ready():
	collider.set_trigger(true)
	activate()


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
	set_fixed_process(true)


func _fixed_process(delta):
	set_pos(Vector2(get_pos().x + SPEED * delta, get_pos().y))
	if get_pos().x > 900:
		queue_free()
