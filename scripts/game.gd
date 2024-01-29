extends Node2D

# game.gd handles all game logic except for the tower.

const SCORE_GOAL: int = 25
const TOWER_WEIGHT_WARNING: float = 25.0
const TOWER_WEIGHT_OVERLOAD: float = 35.0
const WEIGHT_EXP: float = 1.5 # Exponential growth of weight (distance from center)
const WEIGHT_DIVIDER: float = 10.0 # Divide base weight with this.
const TOWER_ROTATION_SPEED: float = 0.05
const TOWER_WEIGHTS: Array = [ # Define all possible weights
	1.0,
	2.0
]
const TOWER_ICON_TEXTURES: Array = [
	"res://assets/textures/characters/char1/icon.tres",
	"res://assets/textures/characters/char2/icon.tres",
]

@onready var character_scene = preload("res://scenes/character.tscn")

static var mouse_pos: Vector2
var mouse_on_platform: bool = false

var is_placing_character: bool = false
var current_char_weight: float = 0.0
var current_char_type: int = -1

var tower_weight: float = 0.0

var score: int = 0
var game_over: bool = false

# Node references
var tower: Object
var current_platform: Object
var arrow_node: Sprite2D # Reference to UI element
var placement_sprite_node: Sprite2D # Reference to UI element


func _ready():
	# Get node references.
	arrow_node = $PlacementArrowSprite
	placement_sprite_node = $PlacementSprite
	tower = $Tower
	
	define_new_character()
	
	Audio.get_node("Music").play()


func _process(_delta):
	_update_placement()
	_apply_weight()
	_update_warning()
	
	# Pressing a button when game is over results in scene change.
	if Input.is_action_just_pressed("continue") and game_over:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
	# When score exceeds goal, game is won.
	if score >= SCORE_GOAL and !game_over:
		_win_game()


func define_new_character() -> void:
	# Get randomized character type from list of characters.
	current_char_type = randi_range(0, TOWER_WEIGHTS.size() - 1)
	
	# Apply character properties accordingly.
	current_char_weight = TOWER_WEIGHTS[current_char_type] # Weight
	$Overlay/NewCharacterButton/Texture.texture = load(
			TOWER_ICON_TEXTURES[current_char_type]) # Texture
	$PlacementSprite.texture = load(
			TOWER_ICON_TEXTURES[current_char_type]) # UI Texture


func _update_placement() -> void:
	mouse_pos = get_global_mouse_position()
	
	# Toggle visibility on UI elements based on character visibility.
	placement_sprite_node.visible = is_placing_character
	arrow_node.visible = is_placing_character
	
	placement_sprite_node.global_position = mouse_pos
	
	# If player is not placing character on a platform, skip.
	if !mouse_on_platform or !is_placing_character:
		arrow_node.visible = false
		return
	
	var new_current_platform = _get_nearest_platform()
	var is_platform_occupied: bool = false
	
	# Check wether the platform is occupied or not.
	if new_current_platform.get_child_count() != 0:
		is_platform_occupied = true
		$PlacementArrowSprite.texture = load(
				"res://assets/textures/ui/placement_occupied.tres") # Texture
		$PlacementArrowSprite.set_self_modulate(
				Color.RED) # Color
	else:
		$PlacementArrowSprite.texture = load(
				"res://assets/textures/ui/placement_free.tres") # Texture
		$PlacementArrowSprite.set_self_modulate(
				Color.WHITE) # Color
	
	arrow_node.global_position = new_current_platform.global_position
	
	# Place character on platform when mouse button is pressed.
	if Input.is_action_just_pressed("mouse1") and !is_platform_occupied:
		_place_character(new_current_platform)


func _update_warning():
	var color: Color
	
	# Check if tower weight goes beyond weight limit.
	if is_tower_weight_exceeded():
		color = Color.RED
	else:
		color = Color.WHITE
	
	# Smoothly change color of the tower.
	tower.set_modulate(
			lerp(tower.get_modulate(), color, 0.1)
	)


func is_tower_weight_exceeded() -> bool:
	var tower_weight_exceeded: bool = tower_weight >= TOWER_WEIGHT_WARNING
	var tower_weight_subceeded: bool = tower_weight <= -TOWER_WEIGHT_WARNING
	
	if tower_weight_exceeded or tower_weight_subceeded:
		return true
	
	return false


func _place_character(new_current_platform: Object) -> void:
	is_placing_character = false
	
	# Instantiate and add new character to scene.
	var new_char = character_scene.instantiate()
	new_current_platform.add_child(new_char)
	new_char.get_node("Sprites").get_child(current_char_type).show()
	
	# Add weight of new character to the tower
	_add_weight(new_char)
	
	define_new_character()
	
	score += 1


func _apply_weight() -> void:
	# Smoothly rotate tower acoording to weight.
	tower.rotation_degrees = lerp(
			tower.rotation_degrees,
			tower_weight,
			TOWER_ROTATION_SPEED)
	
	# Check if tower weight goes beyond weight limit. If so, lose game.
	if is_tower_weight_exceeded():
		_lose_game()


func _add_weight(char_node: Object):
	# Calculate new characters distance from the center of the tower.
	var layer_center_pos: Vector2 = char_node.get_node("../..").global_position
	var distance_from_center: float = char_node.global_position.distance_to(
			layer_center_pos)
	
	# Calculate added weight using exponential growth from the center outwards.
	var weight_to_add: float = pow((
			distance_from_center / WEIGHT_DIVIDER) * current_char_weight,
			WEIGHT_EXP)
	
	# Check characters side and apply weight accordingly.
	if char_node.global_position.x > layer_center_pos.x:
		tower_weight += weight_to_add
	else:
		tower_weight -= weight_to_add


func _get_nearest_platform() -> Object:
	var platforms: Array = []
	
	# Add all platform positions to a list
	for pos_node: Marker2D in current_platform.get_node("Positions").get_children():
		platforms.append(pos_node)
	
	# Update mouse position
	mouse_pos = get_global_mouse_position()
	
	# Sort positions by nearest to furthest
	platforms.sort_custom(sort_by_nearest)
	
	# Get nearest platform
	var nearest_platform: Marker2D = platforms[0]
	return nearest_platform


static func sort_by_nearest(a, b):
	# Sort objects by nearest to mouse position.
	if mouse_pos.distance_to(a.global_position) < mouse_pos.distance_to(b.global_position):
		return true
	return false


func _win_game() -> void:
	game_over = true
	$Overlay.win()


func _lose_game() -> void:
	game_over = true
	$Overlay.lose()


# Signals

func _on_new_character_button_pressed():
	# When new character button is pressed, select new character
	if is_placing_character or game_over:
		return
	
	is_placing_character = true
	
