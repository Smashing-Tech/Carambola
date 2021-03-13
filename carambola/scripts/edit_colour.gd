extends Control

var prop : String = ""
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.color = globals.selection[prop]
	
	hold = globals.selection

func _process(_delta):
	if (hold == globals.selection):
		globals.selection[prop] = $value.color

func set_property(prop_new : String):
	self.prop = prop_new
