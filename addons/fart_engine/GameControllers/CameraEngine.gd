extends GDScript
class_name CameraEngine

var camera_controller :CharacterBody2D
var is_following_player: bool = true




func _ready():
	if !FART.fart_root.has_node("Camera Controller"):
		camera_controller = CharacterBody2D.new()
		FART.fart_root.add_child(camera_controller)
	set_main_camera(await get_default_camera())
	set_camera_smooth_speed(await FART.get_field_value("10012",await FART.get_global_settings_profile(), "Smoothing Speed"))



func get_default_camera()-> Camera2D:
	var default_camera: Camera2D = load(await FART.get_field_value("10012",await FART.get_global_settings_profile(), "Camera Scene")).instantiate()
	default_camera.name = "Camera Controller"
	return default_camera


func set_main_camera(camera : Camera2D):
	if FART.main_camera != null:
		FART.main_camera.call_deferred("queue_free")
	FART.main_camera = camera
	add_camera_to_controller(camera_controller, camera)
	camera.enabled = true


func get_main_camera()-> Camera2D:
	return FART.main_camera


func add_camera_to_controller(controller :CharacterBody2D, camera: Camera2D = get_main_camera()):
	controller.add_child(camera)


func camera_physics_process(delta): #CURRENTLY BEING CALLED FROM PLAYER PHYSICS PROCESS
	if FART.player_node != null:
		if is_instance_valid(camera_controller):
			if camera_controller.is_inside_tree():
				if camera_controller.get_parent().name != "root":
					follow_player(delta)
					camera_controller.move_and_slide()


func follow_player(delta):
	if is_following_player:
		camera_controller.set_global_position(FART.player_node.global_position)


func add_camera_to_map(map_node):
	FART.fart_root.remove_child(camera_controller)
	await FART.get_tree().process_frame
	map_node.add_child(camera_controller)
	camera_controller.set_position(FART.player_node.position)


func remove_camera_from_map():
	if camera_controller != null:
		var camera_parent = camera_controller.get_parent()
		camera_parent.remove_child(camera_controller)
		await FART.get_tree().process_frame
		FART.fart_root.add_child(camera_controller)



#COMMAND
func set_is_following_player(is_following:bool = true):
	is_following_player = is_following

#COMMAND
func move_camera_to_event(event_name: String, return_to_player:bool, how_long:float):

	var event_node: EventHandler = FART.current_map_node.get_node("YSort").get_node_or_null(event_name) #GET NOD EOR NULL
	if event_node != null:
		set_is_following_player(false)
		camera_controller.set_global_position(event_node.get_global_position())
		
		while !round(FART.main_camera.get_screen_center_position()).is_equal_approx(event_node.get_global_position()):
			camera_controller.set_global_position(event_node.get_global_position())
			await FART.get_tree().process_frame
		if return_to_player:
			await FART.get_tree().create_timer(how_long).timeout
		set_is_following_player(return_to_player)
	else:
		print("CANNOT FIND EVENT WITH NAME: ", event_name, " PLEASE BE SURE THAT THE EVENT EXISTS IN MAP: ", await FART.get_map_name(await FART.get_current_map_path()))


#COMMAND
func move_camera(what_direction: Vector2, how_fast: float = 5000.00, how_long: float = 0.25, return_to_player:bool = true, camera :Camera2D = get_main_camera()):
	set_is_following_player(false)
	camera_controller.velocity +=  what_direction.normalized() * how_fast
	await FART.get_tree().create_timer(how_long).timeout
	camera_controller.velocity = Vector2.ZERO
	set_is_following_player(return_to_player)

#COMMAND
func set_camera_smooth_speed(speed:float):
	FART.main_camera.position_smoothing_speed  = speed
