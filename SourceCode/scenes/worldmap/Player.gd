extends Node2D

export var level_dots = [] # An array of all the level dot objects in the worldmap
export var tilemaps = []   # An array of all the tilemap objects in the worldmap

var move_direction = Vector2(0,0)

const MOVE_SPEED = 4 # Must be a power of 2 that's lower than 32

# PATH TILE BITMASK DETECTION
var up_tiles = [186, 146, 18, 58, 178, 154, 50, 26]
var down_tiles = [186, 146, 176, 152, 184, 178, 154, 144]
var left_tiles = [186, 56, 152, 26, 154, 58, 184, 24]
var right_tiles = [186, 56, 178, 58, 184, 48, 50, 176]

func _process(delta):
	if tilemaps == []:
		push_error("Worldmap player node cannot access any tilemaps in the worldmap")
	
	handle_leveldot_collisions()
	
	for t in tilemaps:
		var tilemap : TileMap = t
		var tile_position = tilemap.world_to_map(position)
		var occupied_tile_id = tilemap.get_cellv(tile_position) # The ID of the tile the player is standing on.
		
		if occupied_tile_id != null and occupied_tile_id != -1:
			var tile_name = tilemap.get_tileset().tile_get_name(occupied_tile_id)
			
			if tile_name == "Path":
				handle_path_movement(tilemap, tile_position, occupied_tile_id)
				
				break
	
	position += MOVE_SPEED * move_direction

func handle_path_movement(tilemap : TileMap, tile_position : Vector2, tile_id : int):
	# Get the autotile bitmask of the path tile the player is currently standing on.
	# We will use this for navigation.
	var tile_pos = tilemap.get_cell_autotile_coord(tile_position.x, tile_position.y)
	var bitmask = tilemap.get_tileset().autotile_get_bitmask(tile_id, tile_pos)
	
	var path_directions = []
	
	if bitmask in up_tiles: path_directions.append(Vector2.UP)
	if bitmask in left_tiles: path_directions.append(Vector2.LEFT)
	if bitmask in right_tiles: path_directions.append(Vector2.RIGHT)
	if bitmask in down_tiles: path_directions.append(Vector2.DOWN)
	
	# If the player is grid-aligned we can move
	var is_player_aligned_to_tile = tilemap.map_to_world(tile_position) + Vector2(16,16) == position
	if is_player_aligned_to_tile:
		var proposed_move_direction = get_move_input()
		if path_directions.has(proposed_move_direction): move_direction = proposed_move_direction
		
		if !path_directions.has(move_direction): move_direction = Vector2.ZERO

func get_move_input():
	var move_direction = Vector2.ZERO
	if Input.is_action_pressed("move_left"): move_direction = Vector2.LEFT
	if Input.is_action_pressed("move_right"): move_direction = Vector2.RIGHT
	if Input.is_action_pressed("move_up"): move_direction = Vector2.UP
	if Input.is_action_pressed("duck"): move_direction = Vector2.DOWN
	return move_direction

func handle_leveldot_collisions():
	for leveldot in level_dots:
		if leveldot.position == position:
			if !leveldot.level_cleared:
				print("Stop")
				move_direction = Vector2(0,0)