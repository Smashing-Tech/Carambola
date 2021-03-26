extends Control

var prop : String = ""
var last : int
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.value = globals.selection[prop]
	
	last = $value.value
	hold = globals.selection

func _process(_delta):
	if ($value.value != last):
		if (globals.selection == hold):
			globals.selection[prop] = $value.value
			globals.selection.set_update()
		last = $value.value

func set_property(prop_new : String):
	self.prop = prop_new
