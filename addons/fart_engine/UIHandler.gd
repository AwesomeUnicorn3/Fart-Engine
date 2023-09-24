#@tool
#
#extends GDScript
#class_name UIHandler
#
#signal refresh_all_data
#signal save_complete
#
#
#
#func when_editor_saved():
#	if !DatabaseManager.is_editor_saving:
#		DatabaseManager.is_editor_saving = true
#		if !DatabaseManager.is_uds_main_updating:
#			print("FART MAIN: WHEN EDITOR SAVED  - START")
#			for table_name in DatabaseManager.display_form_dict:
#				var table_node = DatabaseManager.display_form_dict[table_name]["Node"]
#				if table_node != null:
#					if !table_node.is_in_group("Database"):
#						DatabaseManager.display_form_dict[table_name]["Node"]._on_Save_button_up()
#						print(table_name, " SAVE COMPLETE")
#			update_input_actions_table()
#			update_UI_method_table()
#			add_items_to_inventory_table()
#			await get_tree().create_timer(0.2).timeout
#		is_editor_saving = false
#		print("FART MAIN - WHEN EDITOR SAVED - END")
#	save_complete.emit()
#
#
#func connect_signals():
#	pass
