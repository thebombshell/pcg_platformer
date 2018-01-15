
extends KinematicBody2D

export(int, 1, 20) var h_size = 1 setget set_h_size;
export(Vector2) var start_pos = Vector2(0.0, 0.0);
export(Vector2) var end_pos = Vector2(0.0, 0.0);
export(float, 8.0, 20.0) var move_speed = 8.0;

var texture_res = preload("res://assets/textures/sprites.png");
var sprite_list = [];
var is_forward = false;
var pos_alpha = 0.0;
onready var is_ready = true;

func set_h_size(t_h_size):
	
	h_size = t_h_size;
	if is_ready:
		
		update_size();
	
	return;

# create_sprite
func create_sprite(t_position, t_region_rect):
	
	var sprite = Sprite.new();
	sprite.texture = texture_res;
	sprite.centered = false;
	sprite.region_enabled = true;
	sprite.z = -1;
	
	sprite.position = t_position;
	sprite.region_rect = t_region_rect;
	
	sprite_list.append(sprite);
	
	add_child(sprite);
	return sprite;

# clear_sprites
func clear_sprites():
	
	for sprite in sprite_list:
		
		remove_child(sprite);
		sprite.queue_free();
	sprite_list.clear();
	return;

# update_collision
func update_collision():
	
	var collision = get_node("CollisionPolygon2D");
	var new_width = h_size * 16.0;
	collision.polygon = [Vector2(0.0, 0.0), Vector2(new_width, 0.0), Vector2(new_width, 16.0), Vector2(0.0, 16.0)];
	return;

# update_sprites
func update_sprites():
	
	clear_sprites();
	
	if h_size == 1:
		
		create_sprite(Vector2(0.0, 0.0), Rect2(48.0, 16.0, 16.0, 16.0));
	elif h_size == 2:
		
		create_sprite(Vector2(0.0, 0.0), Rect2(0.0, 16.0, 16.0, 16.0));
		create_sprite(Vector2(16.0, 0.0), Rect2(32.0, 16.0, 16.0, 16.0));
	elif h_size >= 3:
		
		create_sprite(Vector2(0.0, 0.0), Rect2(0.0, 16.0, 16.0, 16.0));
		for i in range(h_size - 2):
			
			create_sprite(Vector2((i + 1) * 16.0, 0.0), Rect2(16.0, 16.0, 16.0, 16.0));
		create_sprite(Vector2((h_size - 1) * 16.0, 0.0), Rect2(32.0, 16.0, 16.0, 16.0));
	return;

# update_size
func update_size():
	
	if len(sprite_list) == h_size:
		
		return;
	
	update_collision();
	update_sprites();
	return;

# on_set_back
func on_set_back(setback):
	
	start_pos.x -= setback;
	end_pos.x -= setback;
	return;

# _ready
func _ready():
	
	update_size();
	return;

# _physics_process
func _physics_process(delta):
	
	var distance = start_pos.distance_to(end_pos);
	if distance < 0.001:
		position = start_pos;
		return;
	if is_forward:
		
		pos_alpha += (delta / distance) * move_speed;
		if pos_alpha > 1.0:
			
			is_forward = false;
	else:
		
		pos_alpha -= (delta / distance) * move_speed;
		if pos_alpha < 0.0:
			
			is_forward = true;
	position = start_pos * (1.0 - pos_alpha) + end_pos * pos_alpha;
	
	return;