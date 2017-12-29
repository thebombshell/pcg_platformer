extends Label

onready var is_enabled = false setget set_enabled, get_enabled;
onready var start_text;

func set_enabled(value):
	
	is_enabled = value
	if is_enabled:
		
		text = "# " + start_text;
	else:
		
		text = "_ " + start_text;
	return;

func get_enabled():
	
	return is_enabled;

func _gui_input(event):
	
	if event.is_pressed():
		
		set_enabled(!is_enabled);
	return;

func _ready():
	
	start_text = text;
	set_enabled(false);
	return;