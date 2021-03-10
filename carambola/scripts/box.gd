extends Node

class_name EBox

# Sub-components
var _box : MeshInstance = null
var timeSinceLastPhysicsUpdate : float = 0.0

# Elements
var editor_name : String = "Box" + str(randi() % 1000)
var size : Vector3 = Vector3(0.5, 0.5, 0.5)
var position : Vector3 = Vector3()
var template : String = ""
var reflection : bool = false
var visible : bool = true
var tile : int = 0
var colour : Color = Color(127, 127, 127, 255)

func _ready():
	globals.selection = self

func _physics_process(delta):
	timeSinceLastPhysicsUpdate += delta
	if (timeSinceLastPhysicsUpdate > 0.1):
		updateThis()
		timeSinceLastPhysicsUpdate = 0.0

func updateThis():
	if (_box):
		_box.free()
	
	_box = MeshInstance.new()
	_box.translation = position
	_box.mesh = CubeMesh.new()
	_box.mesh.size = size * 2.0
	
	var mat = SpatialMaterial.new()
	mat.albedo_color = colour
	_box.set_surface_material(0, mat)
	
	var _col = ClickableStaticBody.new()
	var box = BoxShape.new()
	box.set_extents(size)
	var shape = _col.create_shape_owner(box)
	_col.shape_owner_add_shape(shape, box)
	_box.add_child(_col)
	
	self.add_child(_box)

func set_active():
	globals.selection = self

func asXMLElement():
	var s = "<box " 
	s += "pos=\"" + str(position.x) + " " + str(position.y) + " " + str(position.z) + "\" "
	s += "size=\"" + str(size.x) + " " + str(size.y) + " " + str(size.z) + "\" "
	if (template):
		s += "template=\"" + template + "\" "
	if (visible):
		s += "visible=\"1\" "
		s += "tile=\"" + str(tile) + "\" "
		var cstr = ""
		cstr += str(colour.r) + " " + str(colour.g) + " " + str(colour.b)
		if (colour.a < 1.0):
			cstr += " " + str(colour.a)
		s += "color=\"" + cstr + "\" "
	s += "/>"
	
	return s
