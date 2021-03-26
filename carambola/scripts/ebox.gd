extends EBase

class_name EBox

# Sub-components
const _Properties = ["editor_name", "position", "size", "template", "reflection", "visible", "tile", "colour"]
var box_mesh_instance : MeshInstance = null

# Elements
var editor_name : String = "Box" + str(randi() % 1000)
var size : Vector3 = Vector3(0.5, 0.5, 0.5)
var position : Vector3 = Vector3()
var template : String = ""
var reflection : bool = false
var visible : bool = true
var tile : int = 0
var colour : Color = Color(0.5, 0.5, 0.5, 1.0)

func _ready():
	globals.selection = self

func _physics_process(delta):
	if (needs_update):
		self.updateThis()
		needs_update = false

func updateThis():
	if (box_mesh_instance):
		box_mesh_instance.free()
	
	box_mesh_instance = MeshInstance.new()
	box_mesh_instance.translation = position
	box_mesh_instance.mesh = CubeMesh.new()
	box_mesh_instance.mesh.size = size * 2.0
	
	var mat = SpatialMaterial.new()
	mat.albedo_color = colour
	mat.albedo_texture = globals.get_tile(tile)
	mat.uv1_triplanar = true
	mat.flags_world_triplanar = true
	
	# Override some visual properties based on templates
	if (globals.templates.get(template, null)):
		if (globals.templates[template].has("tile")):
			mat.albedo_texture = globals.get_tile(int(globals.templates[template].tile))
		if (globals.templates[template].has("color")):
			mat.albedo_color = utils.unpack_colour_string(globals.templates[template].color)
	
	box_mesh_instance.set_surface_material(0, mat)
	
	var collider = ClickableStaticBody.new()
	var box = BoxShape.new()
	box.set_extents(size)
	var shape = collider.create_shape_owner(box)
	collider.shape_owner_add_shape(shape, box)
	box_mesh_instance.add_child(collider)
	
	self.add_child(box_mesh_instance)

func set_active():
	globals.selection = self

func asXMLElement():
	var s = "<box " 
	s += "pos=\"" + str(position.x) + " " + str(position.y) + " " + str(position.z) + "\" "
	s += "size=\"" + str(size.x) + " " + str(size.y) + " " + str(size.z) + "\" "
	if (template):
		s += "template=\"" + template + "\" "
	if (reflection):
		s += "reflection=\"1\" "
	if (visible):
		s += "visible=\"1\" "
		s += "tile=\"" + str(tile) + "\" "
		var cstr = ""
		cstr += str(colour.r) + " " + str(colour.g) + " " + str(colour.b)
		if (colour.a < 1.0):
			cstr += " " + str(colour.a)
		s += "color=\"" + cstr + "\" "
	if (globals.options.enable_carambola_extensions):
		s += "_Name=\"" + editor_name + "\" "
	s += "/>"
	
	return s
