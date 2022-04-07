extends KinematicBody2D
class_name Character

# NO DB = No Database Entry needed for this variable
# DBA - Need to add this variable to the database
# DBAA - Value set from DB Manager

var velocity: = Vector2.ZERO #Needed for movement within the script - NO DB
var gravity: float = 300 #Game gravity (Think of this as y acceleration) - DBAA
#var characterSprite #Character spritesheet texture - DBAA
var characterMaxSpeed #character max speed - DBAA
var characterMass # character mass (maximum down speed)- DBAA
var characterJumpSpeed # character jump speed (jump velocity) - DBAA
var activeCharacterName #Use function get_lead_character() to set value -DBAA

func _ready() -> void:
	activeCharacterName = udsmain.get_lead_character()
	characterMass = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['CharacterMass']
	characterMaxSpeed = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Max Speed']
	characterJumpSpeed = udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Jump Speed']

func _physics_process(delta):
	var direction = get_direction()
	set_velocity(direction, delta)
#	get_gravity()


func get_direction():
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		dir.y = -1.0
	return dir

func set_velocity(direction, delta):
	if direction.x == 0.0: #Left and right movement keys not pressed
		velocity.x = 0
	if direction.y == 0.0: #Up and down Movement keys not pressed
		velocity.y = 0

	if abs(velocity.x) < characterMaxSpeed:
		velocity.x += direction.x * characterMaxSpeed
	if abs(velocity.y) < characterMaxSpeed:
		velocity.y += direction.y * characterMaxSpeed


func get_gravity(): #CURRENTLY NOT BEING USED
	#increase falling speed unless speed is greater than character gravity
	if velocity.y <= characterMass:
		velocity.y += gravity



