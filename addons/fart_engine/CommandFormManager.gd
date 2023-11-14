@tool
class_name CommandFormManager extends CommandManager

static var global_variables_dictionary :Dictionary = {}

@onready var function_name :String = "" #must be name of valid function
var event_name :String = ""
var which_var :String
var to_what :String
var which_field :String
var what :String
var how_many :String
var what_dir :String
var how_fast :float
var how_long :float
var which_map :String
var what_2d_coordinates:Vector2
var destination_node:Node
var distination_scene:Node
var text_input :String

#
#func _ready():
#	if has_method("_on_ready"): call("_on_ready")
