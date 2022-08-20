extends CharacterEngine

@onready var characterBody_node = $Body/FullBody


var state = "IDLE"

var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"


func _ready() -> void:
	if is_inside_tree():
		startup()


func _physics_process(delta: float) -> void:
	char_physics_process(delta)

	if udsmain.Dynamic_Game_Dict.has("Global Data"):
		if udsmain.Dynamic_Game_Dict['Global Data'][udsmain.global_settings]["Is Game Active"]:


			state_machine(delta)
			move_and_slide()

func char_physics_process(delta):
	var direction :Vector2 = get_direction()
	set_vel(direction, delta)
	if direction == Vector2.ZERO:
		state = "IDLE"
		#set animation speed
		characterBody_node.set_speed_scale(1)
	else:
		state = "WALK"
		#set Animation speed
		var anim_speed = (min((abs(velocity.x) + .1/characterMaxSpeed + abs(velocity.y) + .1/characterMaxSpeed ), characterMaxSpeed)/characterMaxSpeed)
		characterBody_node.set_speed_scale(anim_speed)
	

func set_vel(direction, delta):
#	if direction.x == 0.0: #Left and right movement keys not pressed
#		velocity.x = 0
#	if direction.y == 0.0: #Up and down Movement keys not pressed
#		velocity.y = 0

	if abs(velocity.x) < characterMaxSpeed:
		velocity.x += direction.x
	if abs(velocity.y) < characterMaxSpeed:
		velocity.y += direction.y
	velocity = velocity.move_toward(direction * characterMaxSpeed, characterAcceleration * delta)
	

func state_machine(delta):
	match state:
		"IDLE":
			velocity = velocity.move_toward(Vector2.ZERO, characterFriction * delta)
			sprite_animation.play(idle)
			enable_collision(idle)
			udsmain.set_sprite_scale(sprite_animation,idle , player_animation_dictionary)
		"WALK":
			var dir = get_direction()
			if dir.x < 0:
				sprite_animation.play(walk_left)
				enable_collision(walk_left)
				udsmain.set_sprite_scale(sprite_animation,walk_left , player_animation_dictionary)

			elif dir.x > 0:
				sprite_animation.play(walk_right)
				udsmain.set_sprite_scale(sprite_animation,walk_right , player_animation_dictionary)
				enable_collision(walk_right)

			elif dir.y < 0:
				sprite_animation.play(walk_up)
				udsmain.set_sprite_scale(sprite_animation,walk_up , player_animation_dictionary)
				enable_collision(walk_up)

			elif dir.y > 0:
				sprite_animation.play(walk_down)
				udsmain.set_sprite_scale(sprite_animation,walk_down , player_animation_dictionary)
				enable_collision(walk_down)
			

