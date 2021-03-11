extends Control

var prop : String = ""

func _ready():
	$label.text = prop.capitalize()
	
	if (globals.selection):
		$value.color = globals.selection[prop]

func _process(_delta):
	if (globals.selection):
		globals.selection[prop] = $value.color

func set_property(prop_new : String):
	self.prop = prop_new
