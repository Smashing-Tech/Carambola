extends Control

var prop : String = ""
var last : String
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.text = globals.selection[prop]
	
	last = $value.text
	hold = globals.selection

func _process(_delta):
	if ($value.text != last):
		if (globals.selection == hold):
			globals.selection[prop] = $value.text
			globals.selection.set_update()
		last = $value.text

func set_property(prop_new : String):
	self.prop = prop_new
