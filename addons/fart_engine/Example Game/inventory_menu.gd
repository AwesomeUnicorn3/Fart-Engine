extends Control

@onready var inventory_display_node: = preload("res://addons/fart_engine/UI_Manager/item_display.tscn")
var local_inventory_dict: Dictionary = {}
var main_inventory_dict: Dictionary = {}


func _ready():
	FARTENGINE.inventory_updated.connect(on_inventory_update)
	await FARTENGINE.DbManager_loaded
	on_inventory_update()


func on_inventory_update():
	main_inventory_dict = FARTENGINE.Dynamic_Game_Dict["Inventory"]
	for item in main_inventory_dict:
		var item_count:int = int(main_inventory_dict[item]["ItemCount"])
		if !local_inventory_dict.has(item):
			add_item_display_node(item, item_count)
		else:
			update_item_count(item,item_count )


func update_item_count(item_key: String, new_value:int):
#	print("UPDATE ITEM KEY: ", item_key, " WITH NEW VALUE: ", new_value)
	var item_node = local_inventory_dict[item_key]["item_node"]
	item_node.update_label(new_value)
	if new_value > 0:
		item_node.visible = true


func add_item_display_node(item_key:String, item_count:int):
#	print("ADD ITEM: ", item_key, " WITH NEW VALUE: ", item_count)
	var new_node: = inventory_display_node.instantiate()
	local_inventory_dict[item_key] = {"item_count" : item_count, "item_node": new_node}
	var new_node_texture: Texture2D = load(FARTENGINE.Static_Game_Dict["Items"][item_key]["Icon"])
	add_child(new_node)
	new_node.update_texture(new_node_texture)
	update_item_count(item_key, item_count)
	if item_count <=0:
		new_node.visible = false
