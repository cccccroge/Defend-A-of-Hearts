extends Node2D
signal is_dead
signal energy_changed
signal life_changed
signal ulty_changed
signal should_generate_gravity_effect(pos)

# nodes
onready var effect_boost = get_node("KinematicBody2D/Effect_BOOST")
onready var effect_gravity_src = load("res://scene/character/Effect_GRAVITY.tscn")

# information
var table_w
var table_h
var size
var pos = Vector2()
var dir = Vector2()
var velocity = Vector2()
var isBoost
var haveHole

# basic properties
export(int) var MOVING_SPEED
export(int) var X_OFFSET
export(int) var MOVING_RANGE
var life
var energy
var ulty

# abilities
export(float) var RESTORE_ENERGY_SPEED
export(float) var CONSUME_ENERGY_SPEED_BOOSTED
export(int) var CONSUME_ENERGY_ANTI_GRAVITY
export(int) var CONSUME_ENERGY_GROW_UP
export(int) var CONSUME_ENERGY_ULTIMATE
export(float) var CHARGING_ULT_SPEED
export(float) var BOOSTED_FACTOR
export(int) var GRAVITY_RANGE
export(int) var GROW_UP_SCALE
export(int) var ESCAPE_SPEED

# states
var velocity_state
var effect_state
var scale_state
enum VELOCITY_STATE { IDLE, MOVE, BOOSTED }
enum EFFECT_STATE { NORMAL, BOOSTED, TRAPPED }
enum SCALE_STATE { NORMAL, GIANT }


func _ready():
	table_w = get_viewport_rect().size.width
	table_h = get_viewport_rect().size.height - 100
	size = get_node("KinematicBody2D/Sprite").get_texture().get_size()
	
	effect_boost.hide()
	
	pos = get_pos()
	
	set_process(true)
	set_process_input(true)
	
	reset()


func _input(event):
	# read inputs
	if event.is_action_pressed("LEFT_1"): 
		dir += Vector2(-1, 0)
	elif event.is_action_released("LEFT_1"):
		dir -= Vector2(-1, 0)
	if event.is_action_pressed("RIGHT_1"):
		dir += Vector2(1, 0)
	elif event.is_action_released("RIGHT_1"):
		dir -= Vector2(1, 0)
	if event.is_action_pressed("UP_1"):
		dir += Vector2(0, -1)
	elif event.is_action_released("UP_1"):
		dir -= Vector2(0, -1)
	if event.is_action_pressed("DOWN_1"):
		dir += Vector2(0, 1)
	elif event.is_action_released("DOWN_1"):
		dir -= Vector2(0, 1)
	if event.is_action_pressed("BOOST_1"):
		isBoost = true
	elif event.is_action_released("BOOST_1"):
		isBoost = false
	if event.is_action_pressed("ANTI_GRAVITY_1"):
		if energy >= CONSUME_ENERGY_ANTI_GRAVITY:
			activate_gravity_hole()
	
	# decide states (partial)
	if dir.length() > 0:
		if isBoost and energy >= CONSUME_ENERGY_SPEED_BOOSTED * get_process_delta_time():
			velocity_state = VELOCITY_STATE.BOOSTED
		else:
			velocity_state = VELOCITY_STATE.MOVE
	else:
		velocity_state = VELOCITY_STATE.IDLE
	
	if dir.length() > 0 and isBoost and energy >= CONSUME_ENERGY_SPEED_BOOSTED * get_process_delta_time():
		effect_state = EFFECT_STATE.BOOSTED
	else:
		effect_state = EFFECT_STATE.NORMAL


func _process(delta):
	# update depends on states...
	# VELOCITY_STATE
	if velocity_state == VELOCITY_STATE.IDLE and energy < 100:
		velocity = Vector2(0, 0)
		energy += RESTORE_ENERGY_SPEED * delta
		emit_signal("energy_changed")
	else:
		velocity = dir.normalized() * MOVING_SPEED * delta
		if velocity_state == VELOCITY_STATE.MOVE:
			pos += velocity
		elif velocity_state == VELOCITY_STATE.BOOSTED:
			velocity *= BOOSTED_FACTOR
			pos += velocity
			if energy > 0:
				energy -= CONSUME_ENERGY_SPEED_BOOSTED * delta
			else:
				energy = 0
			emit_signal("energy_changed")
		
		pos.x = clamp(pos.x, table_w / 2 - X_OFFSET - MOVING_RANGE, table_w / 2 - X_OFFSET + MOVING_RANGE)
		pos.y = clamp(pos.y, 15 + size.y / 2, table_h - 15 - size.y / 2)
		set_pos(pos)

	# EFFECT_STATE
	if effect_state == EFFECT_STATE.NORMAL:
		effect_boost.hide()
	elif effect_state == EFFECT_STATE.BOOSTED:
		effect_boost.show()
	elif effect_state == EFFECT_STATE.TRAPPED:
		print("effect_state: TRAPPED")
	
	# GENERAL
	if ulty < 100:
		ulty += CHARGING_ULT_SPEED * delta
		emit_signal("ulty_changed")


func reset():
	isBoost = false
	haveHole = false
	
	life = 5
	energy = 100.0
	ulty = 0.0
	
	velocity_state = VELOCITY_STATE.IDLE
	effect_state = EFFECT_STATE.NORMAL
	scale_state = SCALE_STATE.NORMAL
	
	pos = Vector2(table_w / 2 - X_OFFSET, table_h / 2)
	set_pos(pos)
	show()


func set_active(boolean):
	set_process_input(boolean)
	set_process(boolean)


func update_life(num):
	life = num
	if life == 0:
		emit_signal("is_dead")
	else:
		emit_signal("life_changed")


func _on_player_hole_finished():
	haveHole = false


func activate_gravity_hole():
	var gravity_projectile = load("res://scene/character/Effect_GRAVITY_projectile.tscn").instance()
	gravity_projectile.init(1)
	var gravity_projectile_rigidbody = gravity_projectile.get_node("Projectile")
	gravity_projectile.set_as_toplevel(true)
	gravity_projectile_rigidbody.set_pos(pos)
	add_child(gravity_projectile)
	var launch_velocity = velocity * gravity_projectile.velocity_factor / get_process_delta_time()
	gravity_projectile_rigidbody.set_linear_velocity(launch_velocity)
	
	energy -= CONSUME_ENERGY_ANTI_GRAVITY
