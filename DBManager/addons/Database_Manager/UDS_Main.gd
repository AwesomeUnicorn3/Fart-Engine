extends Node
tool
onready var tabs = $Tabs
onready var Database_Editor = $Tabs/Database_Manager
onready var Inventory = $Tabs/Inventory_Manager
onready var quest_menu = $Tabs/Quest
onready var navigation_tabs = $HBox_1/VBox_1/Hbox_1


func hide_all_tabs(): #Hides all of the modules
	for i in tabs.get_children():
		i.visible = false

func enable_navigation_buttons(): #Enables all Navigation buttons
	for i in navigation_tabs.get_children():
		i.disabled = false
	

func _on_Database_Editor_button_up():#Navigate to Database Editor
	hide_all_tabs()
	enable_navigation_buttons()
	Database_Editor.visible = true
	$HBox_1/VBox_1/Hbox_1/Database_Editor.disabled = true

func _on_Inventory_button_up():#Navigate to Inventory Editor
	hide_all_tabs()
	enable_navigation_buttons()
	Inventory.visible = true
	$HBox_1/VBox_1/Hbox_1/Inventory.disabled = true

func _on_Quest_button_up():#Navigate to Quest Editor
	hide_all_tabs()
	enable_navigation_buttons()
	quest_menu.visible = true
	$HBox_1/VBox_1/Hbox_1/Quest.disabled = true
