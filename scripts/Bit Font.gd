extends Object

static func add_characters(t_font, t_position, t_size, t_char_array):
	
	var offset = 0;
	for character in t_char_array:
		
		t_font.add_char(character, 0, Rect2(t_position.x + offset * t_size.x, t_position.y, t_size.x, t_size.y));
		offset += 1;
	return t_font;