extends GDScript
class_name CameraEngine

var camera_controller :CharacterBody2D

func _ready():
	if !FARTENGINE.root.has_node("Camera Controller"):
		camera_controller = CharacterBody2D.new()
		FARTENGINE.root.add_child(camera_controller)
	
	set_main_camera(await get_default_camera())




func get_default_camera()-> Camera2D:
#	var default_camera_key: String = FARTENGINE.get_field_value("Global Data",await FARTENGINE.get_global_settings_profile(), "Default Camera")
	var default_camera: Camera2D = load(FARTENGINE.get_field_value("Camera List",await FARTENGINE.get_global_settings_profile(), "Camera Scene")).instantiate()
	default_camera.name = "Camera Controller"

#	var newgame = FARTENGINE.get_field_value("Global Data",await FARTENGINE.get_global_settings_profile(), "NewGame")

	return default_camera


func set_main_camera(camera : Camera2D):
	if FARTENGINE.main_camera != null:
		FARTENGINE.main_camera.call_deferred("queue_free")
	FARTENGINE.main_camera = camera

	add_camera_to_controller(camera_controller, camera)

	camera.enabled = true


func get_main_camera()-> Camera2D:
	return FARTENGINE.main_camera


func add_camera_to_controller(controller :CharacterBody2D, camera: Camera2D = get_main_camera()):
	controller.add_child(camera)


func follow_player():
	if camera_controller.is_inside_tree():
		if is_instance_valid(camera_controller) and FARTENGINE.player_node != null and camera_controller.get_parent().name != "root":
			camera_controller.velocity = FARTENGINE.player_node.velocity
			camera_controller.move_and_slide()


func move_camera_up(camera :Camera2D = get_main_camera()):
	camera_controller.velocity +=  Vector2(0,-15)
	camera_controller.move_and_slide()

#func move_camera(direction: Vector2, delta, camera: Camera2D = get_main_camera()):
#	camera.
	
func add_camera_to_map(map_node):
	FARTENGINE.root.remove_child(camera_controller)
	await FARTENGINE.get_tree().process_frame
	map_node.add_child(camera_controller)
	camera_controller.set_position(FARTENGINE.player_node.position)


func remove_camera_from_map():
	var camera_parent = camera_controller.get_parent()
	camera_parent.remove_child(camera_controller)
	await FARTENGINE.get_tree().process_frame
	FARTENGINE.root.add_child(camera_controller)
