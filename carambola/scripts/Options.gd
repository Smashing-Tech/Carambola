extends WindowDialog

func _ready():
	$Save.connect("pressed", self, "save_settings")

func save_settings():
	globals.options.enable_carambola_extensions = $CarambolaExt.pressed
	globals.options.save_backup_scene = $Backup.pressed
	globals.save_options()

func on_show():
	$CarambolaExt.pressed = globals.options.enable_carambola_extensions
	$Backup.pressed = globals.options.save_backup_scene
