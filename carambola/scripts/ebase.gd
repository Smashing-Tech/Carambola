extends Node

class_name EBase

# Update functionality
var needs_update : bool = true

func set_update():
	# set the update flag for this object
	needs_update = true
