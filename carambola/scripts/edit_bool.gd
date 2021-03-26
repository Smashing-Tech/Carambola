extends Control

var prop : String = ""
var last : bool # The last value of textbox, so we know if update is needed
var hold

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.pressed = globals.selection[prop]
	
	$value.text = $label.text
	
	last = $value.pressed
	hold = globals.selection

func _process(_delta):
	if ($value.pressed != last):
		if (globals.selection == hold):
			globals.selection[prop] = $value.pressed
			globals.selection.set_update()
		last = $value.pressed

func set_property(prop_new : String):
	self.prop = prop_new
