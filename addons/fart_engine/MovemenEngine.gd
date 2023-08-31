extends CharacterBody2D
class_name MovementEngine

signal sprite_anim_complete

var previous_state :String
var state :String = "idle"
var direction_string :String = "Down"
var previous_direction_string :String = "Down"


func set_character_velocity(curr_velocity:Vector2,direction:Vector2,characterMaxSpeed:float, characterFriction:float,characterAcceleration:float, is_gravity_active:bool,  delta):

	var VELOCITY = curr_velocity
	if is_gravity_active:
		if direction == Vector2.ZERO:
			VELOCITY.x = VELOCITY.move_toward(Vector2.ZERO, characterFriction * delta).x
		else:
			VELOCITY.x = VELOCITY.move_toward(direction * characterMaxSpeed, characterAcceleration * delta).x

	elif !is_gravity_active:
		if VELOCITY.x < characterMaxSpeed:
			VELOCITY.x += direction.x
		if VELOCITY.y < characterMaxSpeed:
			VELOCITY.y += direction.y

		if direction == Vector2.ZERO:
			VELOCITY = VELOCITY.move_toward(Vector2.ZERO, characterFriction * delta)
		else:
			VELOCITY = VELOCITY.move_toward(direction * characterMaxSpeed, characterAcceleration * delta)

	return VELOCITY



func get_direction_string(direction:Vector2):
	var direction_string :String = "Idle"
	var movement_dict :Dictionary = FARTENGINE.Static_Game_Dict["Movement Directions"]
	for key in movement_dict:
		var directionVector :Vector2 = FARTENGINE.convert_string_to_vector(movement_dict[key]["Direction Vector"])
		if direction == directionVector:
			direction_string =  FARTENGINE.get_text(movement_dict[key]["Display Name"])
			break
	return direction_string


func play_sprite_animation(direction :Vector2, sprite_animation,shadow_sprite_animation, draw_shadow, runOnce :bool = false):
	var direction_string :String = get_direction_string(direction)
	if previous_state != state:
		previous_state = state
		sprite_animation.visible = true
		for child in $AnimSprites.get_children():
			if child is AnimatedSprite2D:
				if child.name != state:
					child.visible = false
		if draw_shadow and shadow_sprite_animation != null:
			shadow_sprite_animation.visible = true
			for child in $ShadowAnimSprites.get_children():
				if child is AnimatedSprite2D:
					if child.name != state:
						child.visible = false

	if direction_string == "Idle":
		direction_string = previous_direction_string
		
	if sprite_animation.sprite_frames.has_animation(direction_string):
		previous_direction_string = direction_string
		sprite_animation.play(direction_string)
	else:
		direction_string = previous_direction_string
		sprite_animation.play(previous_direction_string)

	if state == "Jump":
		pass
		#(direction_string)
	if draw_shadow:
		if shadow_sprite_animation.sprite_frames.has_animation(direction_string):
			shadow_sprite_animation.play(direction_string)

	if runOnce:
		await sprite_animation.animation_finished
		sprite_animation.stop()
		shadow_sprite_animation.stop()
		emit_signal("sprite_anim_complete")
