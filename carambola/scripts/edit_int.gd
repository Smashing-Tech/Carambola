extends Control

var prop : String = ""
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.text = str(globals.selection[prop])
	
	hold = globals.selection

func _process(_delta):
	if (globals.selection == hold):
		globals.selection[prop] = int($value.text)

func set_property(prop_new : String):
	self.prop = prop_new
