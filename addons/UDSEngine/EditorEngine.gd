@tool
extends Node
signal Editor_Refresh_Complete
var editorInterface :EditorInterface 


func refresh_editor(parent):
	get_editor_interface().get_resource_filesystem().scan()
	while editorInterface.get_resource_filesystem().is_scanning():
		print("Scanning...")
		await parent.get_tree().process_frame
	await parent.get_tree().create_timer(.1).timeout
	emit_signal("Editor_Refresh_Complete")
	print("Scanning Complete")


func get_editor_interface():
	editorInterface  = EditorScript.new().get_editor_interface()
	return editorInterface
