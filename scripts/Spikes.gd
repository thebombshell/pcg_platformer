
extends KinematicBody2D

export(int, 1, 20) var h_size = 1 setget set_h_size;
var texture_res = preload("res://assets/textures/sprites.png");
var sprite_list = [];
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
	for i in range(h_size):
		create_sprite(Vector2(i * 16.0, 0.0), Rect2(176.0, 16.0, 16.0, 16.0));
	return;

# update_size
func update_size():
	
	if len(sprite_list) == h_size:
		
		return;
	
	update_collision();
	update_sprites();
	return;

# _ready
func _ready():
	
	update_size();
	pass;
