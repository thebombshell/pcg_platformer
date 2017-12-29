extends Object

const acceleration = 240.0;
const decceleration = 240.0;
const max_speed = 80.0;
const jump_strength = 96.0;
const death_height = 128.0;
enum PLAYER_STATE {
	
	IDLE,
	RUNNING,
	JUMPING,
	FALLING
};

static func get_acceleration():
	
	return acceleration;

static func get_decceleration():
	
	return decceleration;

static func get_max_speed():
	
	return max_speed;

static func get_jump_strength():
	
	return jump_strength;

static func get_death_height():
	
	return death_height;