extends Control

var prop : String = ""
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.pressed = globals.selection[prop]
	
	hold = globals.selection

func _process(_delta):
	$value.text = $label.text
	
	if (globals.selection == hold):
		globals.selection[prop] = $value.pressed

func set_property(prop_new : String):
	self.prop = prop_new
