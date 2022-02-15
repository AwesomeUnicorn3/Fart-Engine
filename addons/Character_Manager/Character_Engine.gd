extends KinematicBody2D
class_name Character

# NO DB = No Database Entry needed for this variable
# DBA - Need to add this variable to the database

var velocity: = Vector2.ZERO #Needed for movement within the script - NO DB

var gravity: float = 300 #Game gravity (Think of this as y acceleration) - DBA
var characterSprite #Character spritesheet texture - DBA
var characterMaxSpeed #character max speed - DBA
var characterMass # character mass (maximum down speed)- DBA
var characterJumpSpeed # character jump speed (jump velocity) - DBA

func _ready() -> void:
	var activeCharacterName = "Player" #NEED TO ADD FORMATION TABLE TO GET CHARACTER IN 1ST PLACE, UNTIL THEN, HARD CODE NAME
	characterMass = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['CharacterMass']
	characterSprite = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Walk Sprite']
	characterMaxSpeed = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Max Speed']
	characterJumpSpeed = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Jump Speed']

func _physics_process(delta):
	var direction = get_direction()
	set_velocity(direction, delta)
	get_gravity()
	#increase falling speed unless speed is greater than character gravity

func get_direction():
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		dir.y = -1.0
	return dir

func set_velocity(direction, delta):
	if direction.x == 0.0:
		velocity.x = 0
	if abs(velocity.x) < characterMaxSpeed:
		velocity.x += direction.x * characterMaxSpeed# * delta
	velocity.y += direction.y * characterJumpSpeed

func get_gravity():
	if velocity.y <= characterMass:
		velocity.y += gravity# * delta
