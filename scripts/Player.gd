extends RigidBody2D

# constants
const info = preload("res://scripts/Player Info.gd");
const spikes = preload("res://scripts/Spikes.gd");

# nodes
var camera;
var ground_checker;
var left_safety_checker;
var right_safety_checker;
var sprite;
var ground_platform = null;

# move info
var h_speed = 0.0;
var is_on_ground = false;
var safe_position = Vector2(0.0, 0.0);
var last_ground_pos = Vector2(0.0, 0.0);

# animation info
var animation_timer = 0.0;

# state info
var state = info.PLAYER_STATE.IDLE setget set_state;

# set_state
func set_state(new_state):
	
	if new_state != state:
		
		animation_timer = 0.0;
	state = new_state;
	return;

# process_on_ground
func process_on_ground():
	
	is_on_ground = false;
	for body in ground_checker.get_overlapping_bodies():
		
		if body is spikes:
			
			if body.position.y > position.y:
				
				kill();
			return;
		elif body != self:
			
			is_on_ground = true;
			if ground_platform == body:
				
				#position += ground_platform.position - last_ground_pos;
				last_ground_pos = ground_platform.position;
			elif ground_platform == null:
				
				ground_platform = body;
			last_ground_pos = body.position;
			if left_safety_checker.overlaps_body(body) && right_safety_checker.overlaps_body(body):
				
				safe_position = position;
	if !is_on_ground:
		
		ground_platform = null;
	return;

# process_movement
func process_movement(t_is_pressed, t_direction, t_delta):
	
	if t_is_pressed:
		
		h_speed = h_speed + info.get_acceleration() * t_direction * t_delta;
		if h_speed * t_direction > info.get_max_speed():
			
			h_speed = info.get_max_speed() * t_direction;
		return true;
	elif h_speed * t_direction > 0.0:
		
		h_speed = h_speed - info.get_decceleration() * t_direction * t_delta;
		if h_speed * t_direction < 0.0:
			
			h_speed = 0.0;
	return false;

# process_jump
func process_jump():
	
	if Input.is_action_just_pressed("jump") && is_on_ground:
		
		set_axis_velocity(Vector2(0.0, -info.get_jump_strength()));
	return;

# process_user_input
func process_user_input(t_delta):
	
	var is_move_left = process_movement(Input.is_action_pressed("move_left"), -1.0, t_delta);
	var is_move_right = process_movement(Input.is_action_pressed("move_right"), 1.0, t_delta);
	if is_move_left == is_move_right && is_on_ground:
		
		state = info.PLAYER_STATE.IDLE;
	elif is_on_ground:
		
		sprite.flip_h = is_move_left;
		state = info.PLAYER_STATE.RUNNING;
	linear_velocity = Vector2(h_speed, linear_velocity.y);
	process_jump();
	return;

func process_animation(t_delta):
	
	animation_timer += t_delta;
	
	if linear_velocity.y < -1.0:
		
		state = info.PLAYER_STATE.JUMPING;
	elif !is_on_ground:
		
		state = info.PLAYER_STATE.FALLING;
	
	if state == info.PLAYER_STATE.IDLE:
		
		sprite.region_rect.position.x = 0;
		return;
	if state == info.PLAYER_STATE.RUNNING:
		
		if animation_timer < 0.24:
			
			sprite.region_rect.position.x = 16;
		elif animation_timer < 0.48:
			
			sprite.region_rect.position.x = 32;
		else:
			
			animation_timer -= 0.48;
			sprite.region_rect.position.x = 16;
		return;
	elif state == info.PLAYER_STATE.JUMPING:
		
		sprite.region_rect.position.x = 48;
		return;
	elif state == info.PLAYER_STATE.FALLING:
		
		sprite.region_rect.position.x = 64;
		return;
	return;

# kill
func kill():
	
	print("am kill");
	position = safe_position + Vector2(0.0, -16.0);
	return;

# _ready
func _ready():
	
	camera = get_node("Camera");
	ground_checker = get_node("Ground Checker");
	left_safety_checker = get_node("Left Safety Checker");
	right_safety_checker = get_node("Right Safety Checker");
	sprite = get_node("Sprite");
	return;

# _process
func _process(t_delta):
	
	process_animation(t_delta);
	camera.align();
	if position.y > info.get_death_height():
		
		kill();
	return;

# _physics_process
func _physics_process(t_delta):
	
	process_on_ground();
	process_user_input(t_delta);
	return;
