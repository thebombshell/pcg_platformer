extends Node2D

# constants
const player_info = preload("res://scripts/Player Info.gd");
const bit_font = preload("res://scripts/Bit Font.gd");
const sprite_tex = preload("res://assets/textures/sprites.png");
const char_array_a = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 46, 44, 33, 63, 95, 35 ];
const char_array_b = [97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 32 ];
const moving_platform = preload("res://scripts/Moving Platform.gd");
# prefabs
const platform_prefab = preload("res://objects/Platform.tscn");
const moving_platform_prefab = preload("res://objects/Moving Platform.tscn");
const spike_prefab = preload("res://objects/Spike.tscn");

# objects
var player;
var ui;

var random_variation;
var hazard_variation;
var difficulty_scaling;
var variation_staggering;
var cosmetic_generation;
var option_f;

# generator info
var last_platform = null;
var end_position = Vector2(-640.0, 0.0);
var minor_difficulty = 0.0;
var major_difficulty = 0.0;

# generator weights
var jump_chance = 1.0;
var drop_chance = 1.0;
var platform_chance = 1.0;
var spike_chance = 1.0;

# get_gravity_strength
func get_gravity_strength():
	
	return Physics2DServer.area_get_param(get_world_2d().get_space(), Physics2DServer.AREA_PARAM_GRAVITY);

# get_jump_height
func get_jump_height(t_alpha):
	
	var height = pow(player_info.get_jump_strength(), 2.0) / (get_gravity_strength() * 2.0);
	var jump_interval = floor((height * (1.0 - t_alpha * t_alpha)) / 16.0);
	if difficulty_scaling.is_enabled:
		
		jump_interval = min(1.0 + floor((height * major_difficulty) / 16.0), jump_interval);
	return jump_interval * 16.0;

# get_jump_time
func get_jump_time():
	
	return (player_info.get_jump_strength() / get_gravity_strength()) * 2.0;

# get_jump_distance
func get_jump_distance(t_alpha):
	
	var distance = floor(get_jump_time() * player_info.get_max_speed() / 16.0) * 16.0;
	var jump_interval = max(1.0, floor((distance * t_alpha) / 16.0) - 1);
	if difficulty_scaling.is_enabled:
		
		jump_interval = min(1.0 + floor((distance * major_difficulty) / 16.0), jump_interval);
	return jump_interval * 16.0;

# create_plaform
func create_platform(t_position, t_size):
	
	var platform = platform_prefab.instance();
	platform.position = t_position;
	platform.h_size = t_size;
	add_child(platform);
	return platform;

# create_moving_platform
func create_moving_platform(t_start, t_end, t_size, t_speed):
	
	var platform = moving_platform_prefab.instance();
	platform.position = t_start;
	platform.start_pos = t_start;
	platform.end_pos = t_end;
	platform.h_size = t_size;
	platform.move_speed = t_speed;
	add_child(platform);
	return platform;

# create_spikes
func create_spikes(t_position, t_size):
	
	var spike = spike_prefab.instance();
	spike.position = t_position;
	spike.h_size = t_size;
	add_child(spike);
	return spike;

# get_level_length
func get_level_length():
	
	return 640.0;

# find_target_length
func find_target_length():
	
	var size = 8;
	if random_variation.is_enabled:
		
		size = (randi() % 8) + 1;
	if difficulty_scaling.is_enabled:
		
		size = max(1, floor(8.0 * (1.0 - major_difficulty)));
	return size;

# find_spike_length
func find_spike_length(t_max_length = 4):
	
	if t_max_length - 1 <= 1:
		
		return 0;
	
	var length = t_max_length;
	if random_variation.is_enabled:
		
		length = 1 + floor(randf() * (t_max_length - 1.0));
	return length;

# find_target_position
func find_target_position(t_alpha):
	
	var target_position = end_position + Vector2(get_jump_distance(t_alpha), -get_jump_height(t_alpha));
	target_position.y = min(0.0, target_position.y);
	return target_position;

# find_jump_alpha
func find_jump_alpha(t_min = 0.0, t_max = 1.0):
	
	var jump_alpha = t_min;
	if random_variation.is_enabled:
		
		var alpha = randf();
		jump_alpha = t_max * alpha + t_min * (1.0 - alpha);
	if difficulty_scaling.is_enabled:
		
		jump_alpha = min(t_max * major_difficulty, max(t_max * minor_difficulty, jump_alpha));
	return jump_alpha;

# find_platform_movement
func find_platform_movement(t_max_horizontal = 4, t_max_vertical = -4):
	
	var movement = Vector2(1, -1);
	if random_variation.is_enabled:
		
		movement += Vector2(floor(randf() * (t_max_horizontal - 1)), -floor(randf() * (t_max_vertical - 1)));
	movement = Vector2(min(t_max_horizontal, movement.x), min(t_max_vertical, movement.y));
	return movement * 16.0;

# find_platform_speed
func find_platform_speed():
	
	var speed = 8.0;
	if random_variation.is_enabled:
		
		var alpha = randf();
		speed = 8.0 * (1.0 - alpha) + 20.0 * alpha;
	return speed;

# generate_jump
func generate_jump(t_min_alpha = 0.0, t_max_alpha = 1.0):
	
	var jump_alpha = find_jump_alpha(t_min_alpha, t_max_alpha);
	var target_position = find_target_position(jump_alpha);
	var target_length = find_target_length();
	var platform = create_platform(target_position, target_length);
	end_position = target_position + Vector2((target_length - 1.0) * 16.0, 0.0);
	return platform;

# generate_horizontal_jump
func generate_horizontal_jump():
	
	last_platform = generate_jump(0.4, 1.0);
	return;

# generate_vertical_jump
func generate_vertical_jump():
	
	last_platform = generate_jump(0.0, 0.4);
	return;

# generate_drop
func generate_drop():
	
	var target_length = find_target_length();
	last_platform = create_platform(end_position + Vector2(16.0, 32.0), target_length);
	end_position = end_position + Vector2(16.0 + target_length * 16.0, 32.0);
	return;

# generate_moving_platform
func generate_moving_platform(t_min_alpha = 0.0, t_max_alpha = 1.0, t_max_horizontal = 4, t_max_vertical = -4):
	
	var jump_alpha = find_jump_alpha(t_min_alpha, t_max_alpha);
	var distance = find_platform_movement(t_max_horizontal, t_max_vertical);
	var speed = find_platform_speed();
	var target_position = find_target_position(jump_alpha);
	var target_length = find_target_length();
	var platform = create_moving_platform(target_position, target_position + distance, target_length, speed);
	end_position = target_position + Vector2((target_length - 1.0) * 16.0, 0.0) + distance;
	return platform;

# generate_horizontal_moving_platform
func generate_horizontal_moving_platform():
	
	last_platform = generate_moving_platform(0.4, 1.0, 4, 0);
	return;

# generate_vertical_moving_platform
func generate_vertical_moving_platform():
	
	last_platform = generate_moving_platform(0.0, 0.4, 0, -4);
	return;

# generate_diagonal_moving_platform
func generate_diagonal_moving_platform():
	
	last_platform = generate_moving_platform(0.0, 1.0, 4, 4);
	print(last_platform is moving_platform);
	return;

# generate_spikes
func generate_spikes():
	
	var target_length = 2 + find_target_length();
	last_platform = create_platform(end_position + Vector2(16.0, 0.0), target_length);
	if target_length > 3:
		
		var spike_length = find_spike_length(max(1, target_length - 2));
		create_spikes(end_position + Vector2(target_length * 8.0 - spike_length * 8.0 + 16.0, -16.0), spike_length);
		end_position = end_position + Vector2(target_length * 16.0, 0.0);
	return;

# generate_spike_jump
func generate_spikes_jump():
	
	var platform = generate_jump(0.2, 0.8);
	if platform.h_size > 4:
		
		var spike_length = find_spike_length(platform.h_size - 2);
		if spike_length > 0:
			
			create_spikes(platform.position + Vector2(-platform.h_size * 8.0 - spike_length * 8.0, 0.0), spike_length);
	last_platform = platform;
	return;

# generate
func generate():
	
	if hazard_variation.is_enabled:
		
		var jump_ratio = 1.0;
		var drop_ratio = 2.0;
		var platform_ratio = 1.0;
		var spike_ratio = 1.0;
		
		if difficulty_scaling.is_enabled:
			
			minor_difficulty += 0.2;
			if minor_difficulty > major_difficulty * 10.0:
				
				minor_difficulty = 0.0;
				major_difficulty = min(major_difficulty + 0.1, 1.0);
			pass;
		if variation_staggering.is_enabled:
			
			jump_chance = max(0.05, jump_chance + 0.05);
			drop_chance = max(0.05, drop_chance + 0.05);
			platform_chance = max(0.05, platform_chance + 0.05);
			spike_chance = max(0.05, spike_chance + 0.05);
			jump_ratio = jump_chance;
			drop_ratio = drop_chance;
			platform_ratio = platform_chance;
			spike_ratio = spike_chance;
			pass;
		
		if last_platform is moving_platform:
			
			platform_ratio = 0.0;
		
		var total_chance = jump_ratio + drop_ratio + platform_ratio + spike_ratio;
		var hazard = randf() * total_chance;
		jump_ratio = jump_ratio;
		drop_ratio = jump_ratio + drop_ratio;
		platform_ratio = drop_ratio + platform_ratio;
		spike_ratio = platform_ratio + spike_ratio;
		
		if hazard < jump_ratio:
			
			hazard = randf();
			jump_chance -= 0.2;
			if hazard < 0.5:
				
				generate_horizontal_jump();
			else:
				
				generate_vertical_jump();
		elif hazard < drop_ratio:
			
			generate_drop();
			drop_chance -= 0.2;
		elif hazard < platform_ratio:
			
			hazard = randf();
			platform_chance -= 0.2;
			if hazard < 0.333:
				
				generate_horizontal_moving_platform();
			elif hazard <= 0.666:
				
				generate_vertical_moving_platform();
			else:
				
				generate_diagonal_moving_platform();
		else:
			
			hazard = randf();
			spike_chance -= 0.2;
			if hazard < 0.5:
				
				generate_spikes();
			else:
				
				generate_spikes_jump();
		return;
	
	generate_jump();
	return;

# process_generator
func process_generator():
	
	if player.position.x + get_level_length()  > end_position.x:
		
		generate();
	return;

# clean_level
func clean_level():
	
	for node in get_children():
		
		if node.position.x < player.position.x - get_level_length():
			
			node.queue_free();
	return;

# _ready
func _ready():
	
	player = get_node("../Player");
	ui = get_node("../../GUI/Content Generator UI");
	random_variation = ui.get_node("Panel/Random Variation");
	hazard_variation = ui.get_node("Panel/Hazard Variation");
	difficulty_scaling = ui.get_node("Panel/Difficulty Scaling");
	variation_staggering = ui.get_node("Panel/Variation Staggering");
	ui.theme.default_font.add_texture(sprite_tex);
	bit_font.add_characters(ui.theme.default_font, Vector2(0.0, 240.0), Vector2(8.0, 8.0), char_array_a);
	bit_font.add_characters(ui.theme.default_font, Vector2(0.0, 248.0), Vector2(8.0, 8.0), char_array_b);
	last_platform = create_platform(Vector2(0.0, 0.0), 20);
	set_physics_process(true);
	end_position = Vector2(320.0, 0.0);
	return;

# _process
func _physics_process(t_delta):
	
	if player.position.x + get_level_length() > end_position.x:
		
		clean_level();
		generate();
	return;

# reset
func reset():
	
	print("reset");
	return;