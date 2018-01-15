extends "res://scripts/Label Button.gd"

func on_click():
	
	var content_gen = get_node("/root/Scene Node/Contents/Content Generator");
	content_gen.reset();
	return;