extends Node2D

# constants
const player_info = preload("res://scripts/Player Info.gd");
const bit_font = preload("res://scripts/Bit Font.gd");
const sprite_tex = preload("res://assets/textures/sprites.png");
const char_array_a = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 46, 44, 33, 63, 95, 35 ];
const char_array_b = [97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 32 ];

# prefabs
const platform_prefab = preload("res://objects/Platform.tscn");

# objects
var player;
var ui;

var option_a;
var option_b;
var option_c;
var option_d;
var option_e;
var option_f;

# generator info
var end_position = Vector2(-640.0, 0.0);

# get_gravity_strength
func get_gravity_strength():
	
	return Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY);

# get_jump_height
func get_jump_height(alpha):
	
	var height = pow(player_info.get_jump_strength(), 2.0) / (get_gravity_strength() * 2.0);
	var modifier = sin(PI * max(0.5, alpha));
	if option_b.is_enabled:
		
		modifier = (randf() * 2.0 - 1.0) * modifier;
	return floor((modifier * height) / 16.0) * 16.0;

# get_jump_time
func get_jump_time():
	
	return (player_info.get_jump_strength() / get_gravity_strength()) * 2.0;

# get_jump_distance
func get_jump_distance(alpha):
	
	var distance = floor(get_jump_time() * player_info.get_max_speed() / 16.0) * 16.0;
	return max(16.0, distance * alpha - 16.0);

# create_plaform
func create_platform(t_position, t_size):
	
	var platform = platform_prefab.instance(PackedScene.GEN_EDIT_STATE_INSTANCE);
	platform.position = t_position;
	platform.h_size = t_size;
	add_child(platform);
	return platform;

# get_level_length
func get_level_length():
	
	return 640.0;

# find_target_length
func find_target_length():
	
	if option_a.is_enabled:
		
		return (randi() % 8) + 1;
	return 4;

# find_target_position
func find_target_position(alpha):
	
	var target_position = end_position + Vector2(get_jump_distance(alpha), -get_jump_height(alpha));
	target_position.y = min(0.0, target_position.y);
	return target_position;

# generate_jump
func generate_jump():
	
	var jump_alpha = 1.0;
	if option_a.is_enabled:
		
		jump_alpha = randf();
	var target_position = find_target_position(jump_alpha);
	var target_length = find_target_length();
	create_platform(target_position, target_length);
	end_position = target_position + Vector2((target_length - 1.0) * 16.0, 0.0);
	return

# generate
func generate():
	
	if option_b.is_enabled:
		
		var hazard = randf();
		
		generate_jump();
		return;
	
	generate_jump();
	return;

# process_generator
func process_generator():
	
	if player.position.x + get_level_length() > end_position.x:
		
		generate();
	return;

# set_back_level
func set_back_level():
	
	player.position.x -= get_level_length();
	end_position.x -= get_level_length();
	for node in get_children():
		
		if node.position.x < 0.0:
			
			node.queue_free();
		node.position.x -= get_level_length();
	
	return;

# _ready
func _ready():
	
	print("is ready");
	print(get_gravity_strength());
	player = get_node("../Player");
	ui = get_node("../../GUI/Content Generator UI");
	option_a = ui.get_node("Panel/Option A");
	option_b = ui.get_node("Panel/Option B");
	option_c = ui.get_node("Panel/Option C");
	option_d = ui.get_node("Panel/Option D");
	option_e = ui.get_node("Panel/Option E");
	option_f = ui.get_node("Panel/Option F");
	ui.theme.default_font.add_texture(sprite_tex);
	bit_font.add_characters(ui.theme.default_font, Vector2(0.0, 240.0), Vector2(8.0, 8.0), char_array_a);
	bit_font.add_characters(ui.theme.default_font, Vector2(0.0, 248.0), Vector2(8.0, 8.0), char_array_b);
	create_platform(Vector2(0.0, 0.0), 4);
	return;

# _process
func _process(t_delta):
	
	if player.position.x > get_level_length():
		
		set_back_level();
	process_generator();
	return;