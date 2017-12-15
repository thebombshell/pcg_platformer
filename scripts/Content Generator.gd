extends Node2D

# constants
const player_info = preload("res://scripts/Player Info.gd");

# prefabs
const platform_prefab = preload("res://objects/Platform.tscn");

# objects
var player;

# generator info
var end_position = Vector2(-640.0, 0.0);

# get_gravity_strength
func get_gravity_strength():
	
	return Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY);

# get_jump_height
func get_jump_height():
	
	return pow(player_info.get_jump_strength(), 2.0) / (get_gravity_strength() * 2.0);

# get_jump_time
func get_jump_time():
	
	return (player_info.get_jump_strength() / get_gravity_strength()) * 2.0;

# get_jump_distance
func get_jump_distance():
	
	return get_jump_time() * player_info.get_max_speed();

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
	
	return 4;

# find_target_position
func find_target_position():
	
	return end_position + Vector2(get_jump_distance() - 1 * 16, 0.0);

# generate
func generate():
	
	var target_position = find_target_position();
	var target_length = find_target_length();
	create_platform(target_position, target_length);
	end_position = target_position + Vector2((target_length - 1.0) * 16.0, 0.0);
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
	return;

# _process
func _process(t_delta):
	
	if player.position.x > get_level_length():
		
		set_back_level();
	process_generator();
	return;