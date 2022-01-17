tool
extends EditorPlugin

func refresh_data():
	get_editor_interface().get_resource_filesystem().scan()
