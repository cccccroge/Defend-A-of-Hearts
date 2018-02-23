extends Node2D

# nodes & resource
onready var effect_boost = get_node("Effect_BOOST")
onready var effect_gravity_src = load("res://scene/character/Effect_GRAVITY.tscn")
onready var kinematic_body = get_node("KinematicBody2D")
onready var sprite = get_node("KinematicBody2D/Sprite")
onready var collision_shape = get_node("KinematicBody2D/CollisionShape2D")

# signals
signal is_dead
signal energy_changed
signal life_changed
signal ulty_changed
signal should_generate_gravity_effect(pos)
signal sould_gen_umbrella

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
export(float) var X_OFFSET
export(float) var MOVING_RANGE
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
export(int) var GROW_UP_DURATION
export(int) var GROW_UP_BACKOFF_STRENGTH
export(int) var ESCAPE_SPEED

# enum
var velocity_state
var effect_state
enum VELOCITY_STATE { IDLE, MOVE, BOOSTED }
enum EFFECT_STATE { NORMAL, BOOSTED, GIANT, TRAPPED }
enum COLLISION_TYPE { ORIGINAL, DISABLE, GIANT }

# key record dictionary
var key_record = { "UP": false,  "DOWN": false, "LEFT": false, "RIGHT": false, 
		"BOOST": false }


func _ready():
	table_w = get_viewport_rect().size.width
	table_h = get_viewport_rect().size.height - 100
	update_size()

	effect_boost.hide()
	
	pos = get_pos()
	
	set_process(true)
	set_process_input(true)
	
	reset()


func _input(event):
	# read inputs
	if event.is_action_pressed("LEFT_1"): 
		key_record["LEFT"] = true
	if event.is_action_released("LEFT_1"):
		key_record["LEFT"] = false
	if event.is_action_pressed("RIGHT_1"):
		key_record["RIGHT"] = true
	if event.is_action_released("RIGHT_1"):
		key_record["RIGHT"] = false
	if event.is_action_pressed("UP_1"):
		key_record["UP"] = true
	if event.is_action_released("UP_1"):
		key_record["UP"] = false
	if event.is_action_pressed("DOWN_1"):
		key_record["DOWN"] = true
	if event.is_action_released("DOWN_1"):
		key_record["DOWN"] = false
	if event.is_action_pressed("BOOST_1"):
		if effect_state != EFFECT_STATE.GIANT:	# can't boost in GIANT
			key_record["BOOST"] = true
	if event.is_action_released("BOOST_1"):
		key_record["BOOST"] = false
	if event.is_action_pressed("GRAVITY_1"):
		if energy >= CONSUME_ENERGY_ANTI_GRAVITY:
			activate_gravity_hole()
	if event.is_action_pressed("GROW_UP_1"):
		if effect_state != EFFECT_STATE.GIANT:	# only not GIANT
			if velocity_state == VELOCITY_STATE.IDLE:	# and not moving
				if energy >= CONSUME_ENERGY_GROW_UP:
					activate_giant_effect()
	if event.is_action_pressed("ULT_1"):
		activate_ulty()
	
	# decide direction
	dir = Vector2(0, 0)
	if key_record["LEFT"]:
		dir.x -= 1
	if key_record["RIGHT"]:
		dir.x += 1
	if key_record["UP"]:
		dir.y -= 1
	if key_record["DOWN"]:
		dir.y += 1
	
	# decide states (partial)
	if dir.length() > 0:
		if key_record["BOOST"] and energy >= CONSUME_ENERGY_SPEED_BOOSTED * get_process_delta_time():
			velocity_state = VELOCITY_STATE.BOOSTED
		else:
			velocity_state = VELOCITY_STATE.MOVE
	else:
		velocity_state = VELOCITY_STATE.IDLE
	
	if dir.length() > 0 and key_record["BOOST"] and energy >= CONSUME_ENERGY_SPEED_BOOSTED * get_process_delta_time():
		effect_state = EFFECT_STATE.BOOSTED
	
	if !key_record["BOOST"] and effect_state == EFFECT_STATE.BOOSTED:
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
		var rm
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
		
		pos.x = clamp(pos.x, 15 + size.x / 2 - size.x / 3, 
				table_w - 15 - size.x / 2)
		pos.y = clamp(pos.y, 15 + size.y / 2, table_h - 15 - size.y / 2)
		set_pos(pos)

	# EFFECT_STATE
	if effect_state == EFFECT_STATE.NORMAL:
		effect_boost.hide()
	elif effect_state == EFFECT_STATE.BOOSTED:
		effect_boost.show()
	
	# GENERAL
	if ulty < 100:
		ulty += CHARGING_ULT_SPEED * delta
		emit_signal("ulty_changed")


func reset():
	haveHole = false
	set_collision_type(COLLISION_TYPE.ORIGINAL)
	
	life = 5
	energy = 100.0
	ulty = 0.0
	
	velocity_state = VELOCITY_STATE.IDLE
	if effect_state == EFFECT_STATE.GIANT:
		disable_giant_effect()
	elif effect_state == EFFECT_STATE.TRAPPED:
		print("get out trap func!")
	effect_state = EFFECT_STATE.NORMAL
	
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


func activate_giant_effect():
	effect_state = EFFECT_STATE.GIANT
	
	# play expand animation
	get_node("AnimPlayer_GIANT").play("expand")
	
	# add timer to stop the effect
	var giant_effect_timer = Timer.new()
	giant_effect_timer.set_name("Giant_effect_timer")
	giant_effect_timer.set_wait_time(GROW_UP_DURATION)
	giant_effect_timer.set_one_shot(true)
	giant_effect_timer.connect("timeout", self, "disable_giant_effect")
	add_child(giant_effect_timer)
	giant_effect_timer.start()

	# play sound
	get_node("Giant_effect_sound").play("giant_sound_effect")
	
	# subtract energy
	energy -= CONSUME_ENERGY_GROW_UP
	emit_signal("energy_changed")


func disable_giant_effect():
	if effect_state == EFFECT_STATE.GIANT:
		effect_state = EFFECT_STATE.NORMAL
	
		# play shrink animation
		get_node("AnimPlayer_GIANT").play("shrink")
		
		# update size
		size.x *= sprite.get_transform().get_scale().x
		size.y *= sprite.get_transform().get_scale().y
		
		# free timer
		get_node("Giant_effect_timer").queue_free()


func set_collision_type(type):
	if type == COLLISION_TYPE.ORIGINAL:
		var default_shape = CapsuleShape2D.new()
		default_shape.set_radius(17.5)
		default_shape.set_height(12.5)
		
		if kinematic_body.get_shape_count() > 0:
			kinematic_body.remove_shape(0)
		kinematic_body.add_shape(default_shape, 
				Matrix32(deg2rad(90), Vector2(11, -0.4)))
	
	elif type == COLLISION_TYPE.DISABLE:
		if kinematic_body.get_shape_count() > 0:
			kinematic_body.remove_shape(0)
	
	elif type == COLLISION_TYPE.GIANT:
		var giant_shape = CapsuleShape2D.new()
		giant_shape.set_radius(35.0)
		giant_shape.set_height(24.0)
		
		if kinematic_body.get_shape_count() > 0:
			kinematic_body.remove_shape(0)
		kinematic_body.add_shape(giant_shape, 
				Matrix32(deg2rad(90), Vector2(22, -0.4)))


func update_size():
	size = sprite.get_texture().size
	size *= sprite.get_transform().get_scale()


func activate_ulty():
	emit_signal("sould_gen_umbrella")
