extends CharacterEngine



#func char_physics_process(delta):
#	var direction :Vector2 = get_direction()
#	set_vel(direction, delta)
#	if direction == Vector2.ZERO:
#		state = "IDLE"
#		#set animation speed
##		characterBody_node.set_speed_scale(1)
#	else:
#		state = "WALK"
		#set Animation speed
#		var anim_speed = (min((abs(velocity.x) + .1/characterMaxSpeed + abs(velocity.y) + .1/characterMaxSpeed ), characterMaxSpeed)/characterMaxSpeed)
#		characterBody_node.set_speed_scale(anim_speed)
	

#func set_vel(direction, delta):
#	if abs(velocity.x) < characterMaxSpeed:
#		velocity.x += direction.x
#	if abs(velocity.y) < characterMaxSpeed:
#		velocity.y += direction.y
#	velocity = velocity.move_toward(direction * characterMaxSpeed, characterAcceleration * delta)
	


#func play_sprite_animation(animation_name :String):
#	sprite_animation.play(animation_name)
#	enable_collision(animation_name)
#	AU3ENGINE.set_sprite_scale(sprite_animation,animation_name , player_animation_dictionary)
#	if draw_shadow:
#		play_shadow_animation(animation_name)
#
#
#func state_machine(delta):
#	match state:
#		"IDLE":
#			velocity = velocity.move_toward(Vector2.ZERO, characterFriction * delta)
#			play_sprite_animation(idle)
#		"WALK":
#			var dir = get_direction()
#			if dir.x < 0:
#				play_sprite_animation(walk_left)
#
#			elif dir.x > 0:
#				play_sprite_animation(walk_right)
#
#			elif dir.y < 0:
#				play_sprite_animation(walk_up)
#
#			elif dir.y > 0:
#				play_sprite_animation(walk_down)

