extends Node2D

export(float) var ANGER_FACTOR
var who_got_scored
var gravity_effects = Array()	# store gravity effects gen by players

# signals
signal gen_gravity_hole(hole)

func _ready():
	randomize()
	game_reset()

func game_reset():
	# reset objects
	get_node("GameInterface/Player_1").reset()
	get_node("GameInterface/Player_2").reset()
	get_node("GameInterface/GUI_layer/UI_1").reset()
	get_node("GameInterface/GUI_layer/UI_2").reset()
	get_node("Hint").reset()
	
	# clear gravity effects
	var effect_nodes = get_tree().get_nodes_in_group("effect")
	print("about to clear: ", effect_nodes)
	for i in effect_nodes:
		i.queue_free()

	# game process : (start) signals--> (playing) signals--> (gameover)
	get_node("StartTimer").start()
	get_node("Hint").set_text_and_show("get ready")


func _on_StartTimer_timeout():
	get_node("/root/Background_music_transition").play("res://sound/Robobozo.ogg")
	get_node("Hint").hide_text()
	get_node("GameInterface/Ball").random_reset()
	get_node("GameInterface/Ball").set_process(true)


func _on_Left_out_body_enter( body ):
	if body.is_in_group("can_score"):
		print("hit left out")
		play_random_score_sound()
		get_node("GameInterface/Player_1").life -= 1
		get_node("GameInterface/GUI_layer/UI_1").update_life(get_node("GameInterface/Player_1").life)
		get_node("GameInterface/Player_1").update_life(get_node("GameInterface/Player_1").life)
		get_node("GameInterface/Player_1").ulty += 100 * ANGER_FACTOR
		get_node("GameInterface/GUI_layer/UI_1").update_ultimate(get_node("GameInterface/Player_1").ulty)
	
		#get_node("GameInterface/Ball").hide()
		get_node("GameInterface/Ball").enable_collision_shape(false)
		who_got_scored = 1
		if get_node("GameInterface/Player_1").life != 0:
			get_node("BallResetTimer").start()


func _on_Right_out_body_enter( body ):
	if body.is_in_group("can_score"):
		print("hit right out")
		play_random_score_sound()
		get_node("GameInterface/Player_2").life -= 1
		get_node("GameInterface/GUI_layer/UI_2").update_life(get_node("GameInterface/Player_2").life)
		get_node("GameInterface/Player_2").update_life(get_node("GameInterface/Player_2").life)
		get_node("GameInterface/Player_2").ulty += 100 * ANGER_FACTOR
		get_node("GameInterface/GUI_layer/UI_2").update_ultimate(get_node("GameInterface/Player_2").ulty)
	
		#get_node("GameInterface/Ball").hide()
		get_node("GameInterface/Ball").enable_collision_shape(false)
		who_got_scored = 2
		if get_node("GameInterface/Player_2").life != 0:
			get_node("BallResetTimer").start()


func _on_BallResetTimer_timeout():
	get_node("GameInterface/Ball").reset(who_got_scored)


func _on_Player_1_life_changed():
	get_node("GameInterface/GUI_layer/UI_1").update_life(get_node("GameInterface/Player_1").life)


func _on_Player_2_life_changed():
	get_node("GameInterface/GUI_layer/UI_2").update_life(get_node("GameInterface/Player_2").life)


func _on_Player_1_energy_changed():
	get_node("GameInterface/GUI_layer/UI_1").update_energy(get_node("GameInterface/Player_1").energy)


func _on_Player_2_energy_changed():
	get_node("GameInterface/GUI_layer/UI_2").update_energy(get_node("GameInterface/Player_2").energy)


func _on_Player_1_ulty_changed():
	get_node("GameInterface/GUI_layer/UI_1").update_ultimate(get_node("GameInterface/Player_1").ulty)


func _on_Player_2_ulty_changed():
	get_node("GameInterface/GUI_layer/UI_2").update_ultimate(get_node("GameInterface/Player_2").ulty)


func _on_Player_1_is_dead():
	get_node("/root/Background_music_transition").fade_out(0.5)
	get_node("Hint").set_text_and_show("player2 WIN!")
	get_node("Hint").show_buttons()
	get_node("GameInterface/Player_1").hide()
	get_node("GameInterface/Player_2").hide()
	get_node("GameInterface/Ball").hide()
	get_node("GameInterface/Ball").set_process(false)


func _on_Player_2_is_dead():
	get_node("/root/Background_music_transition").fade_out(0.5)
	get_node("Hint").set_text_and_show("player1 WIN!")
	get_node("Hint").show_buttons()
	get_node("GameInterface/Player_1").hide()
	get_node("GameInterface/Player_2").hide()
	get_node("GameInterface/Ball").hide()
	get_node("GameInterface/Ball").set_process(false)


func _on_ReplayButton_pressed():
	game_reset()


func _on_BackButton_pressed():
	get_node("/root/LoadScene").goto_scene("res://scene/Main.tscn")


func _on_BallInvalidTimer_timeout():
	get_node("Hint").set_text_and_show("resetting...")
	get_node("GameInterface/Ball").enable_collision_shape(false)
	get_node("BallResetInvalidTimer").start()


func play_random_score_sound():
	get_node("SamplePlayer").play("heyhey")


func _on_Ball_body_enter( body ):
	if body.is_in_group("player_body"):
		# play sound
		get_node("SamplePlayer").play("da", false)
		
		# if player is GIANT: apply impulse
		if body.get_parent().effect_state == body.get_parent().EFFECT_STATE.GIANT:
			var ball = get_node("GameInterface/Ball")
			ball.apply_impulse(Vector2(0, 0),
					ball.get_linear_velocity().normalized() * body.get_parent().GROW_UP_BACKOFF_STRENGTH)


func _on_Player_1_should_generate_gravity_effect(pos):
	var gravity_projectile = load("res://scene/character/Effect_GRAVITY_projectile.tscn").instance()
	var gravity_projectile_rigidbody = gravity_projectile.get_node("Projectile")
	gravity_projectile.set_draw_behind_parent(true)
	gravity_projectile.set_as_toplevel(true)
	gravity_projectile_rigidbody.set_pos(pos)
	get_node("GameInterface/Player_1").add_child(gravity_projectile)
	
	var launch_velocity = get_node("GameInterface/Player_1").velocity * gravity_projectile.velocity_factor
	gravity_projectile_rigidbody.set_linear_velocity(launch_velocity)


func _on_Player_2_should_generate_gravity_effect( pos ):
	var gravity_projectile = load("res://scene/character/Effect_GRAVITY_projectile.tscn").instance()
	var gravity_projectile_rigidbody = gravity_projectile.get_node("Projectile")
	gravity_projectile.set_draw_behind_parent(true)
	gravity_projectile.set_as_toplevel(true)
	gravity_projectile_rigidbody.set_pos(pos)
	get_node("GameInterface/Player_1").add_child(gravity_projectile)
	
	var launch_velocity = get_node("GameInterface/Player_2").velocity * gravity_projectile.velocity_factor
	gravity_projectile_rigidbody.set_linear_velocity(launch_velocity)


func _on_Boundary_body_enter( body ):
	if body.is_in_group("can_score"):
		print("hit boundary")
		body.random_reset()


func _on_Player_1_sould_start_ulty_anim_left():
	var umbrella_anim = preload("res://scene/character/Effect_Ulty_anim.tscn").instance()
	umbrella_anim.connect("should_gen_umbrella_left", self, 
			"_on_umbrella_anim_should_gen_umbrella_left")
	get_node("GameInterface").add_child(umbrella_anim)


func _on_umbrella_anim_should_gen_umbrella_left():
	var umbrella = preload("res://scene/character/Effect_Ulty.tscn").instance()
	get_node("GameInterface").add_child(umbrella)
	umbrella.activate()


func _on_Player_2_sould_start_ulty_anim_right():
	var umbrella_anim = preload("res://scene/character/Effect_Ulty_anim_2.tscn").instance()
	umbrella_anim.connect("should_gen_umbrella_right", self, 
			"_on_umbrella_anim_should_gen_umbrella_right")
	get_node("GameInterface").add_child(umbrella_anim)


func _on_umbrella_anim_should_gen_umbrella_right():
	var umbrella = preload("res://scene/character/Effect_Ulty_2.tscn").instance()
	get_node("GameInterface").add_child(umbrella)
	umbrella.activate()
