# This is just a StaticBody that has the _input_event function overridden so that
# it will be set as the active object if a click is detected.

class_name ClickableStaticBody

extends StaticBody

func _ready():
	# warning-ignore:return_value_discarded
	self.connect("input_event", self, "_input_event")

func _input_event(_camera : Object, _event : InputEvent, _click_position : Vector3, _click_normal : Vector3, _shape_idx : int):
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		globals.selectionChanged = true
		self.get_parent().get_parent().set_active()
