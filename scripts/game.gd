extends Node2D

const SCORE_GOAL: int = 25
const TOWER_WEIGHT_WARNING: float = 25.0
const TOWER_WEIGHT_OVERLOAD: float = 35.0
const WEIGHT_EXP: float = 1.5 # Exponential growth of weight (distance from center)
const TOWER_WEIGHTS: Array = [
	1.0,
	2.0
]
const TOWER_ICON_TEXTURES: Array = [
	"res://assets/textures/characters/char1/icon.tres",
	"res://assets/textures/characters/char2/icon.tres",
]

@onready var character_scene = preload("res://scenes/character.tscn")

var mouse_on_platform: bool = false
var current_platform: Object
var tower: Object

var is_placing_character: bool = false
var current_char_weight: float = 0.0
var current_char_type: int = -1

var arrow_node: Sprite2D
var placement_sprite_node: Sprite2D

var tower_weight: float = 0.0

var score: int = 0
var game_over: bool = false


func _ready():
	# Get node references
	arrow_node = $PlacementArrowSprite
	placement_sprite_node = $PlacementSprite
	tower = $Tower
	
	define_new_character()
	
	Audio.get_node("Music").play()


func _process(_delta):
	_update_placement()
	_apply_weight()
	_update_warning()
	
	if Input.is_action_just_pressed("continue") and game_over:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
	if score >= SCORE_GOAL and !game_over:
		_win_game()


func define_new_character() -> void:
	current_char_type = randi_range(0, TOWER_WEIGHTS.size() - 1)
	current_char_weight = TOWER_WEIGHTS[current_char_type]
	$Overlay/NewCharacterButton/Texture.texture = load(TOWER_ICON_TEXTURES[current_char_type])
	$PlacementSprite.texture = load(TOWER_ICON_TEXTURES[current_char_type])


func _update_placement() -> void:
	var mouse_pos = get_global_mouse_position()
	
	placement_sprite_node.visible = is_placing_character
	arrow_node.visible = is_placing_character
	
	placement_sprite_node.global_position = mouse_pos
	
	if !mouse_on_platform or !is_placing_character:
		arrow_node.visible = false
		return
	
	var new_current_platform = _get_nearest_platform()
	var is_platform_occupied: bool = false
	
	if new_current_platform.get_child_count() != 0:
		is_platform_occupied = true
		$PlacementArrowSprite.texture = load("res://assets/textures/ui/placement_occupied.tres")
		$PlacementArrowSprite.set_self_modulate(Color.RED)
	else:
		$PlacementArrowSprite.texture = load("res://assets/textures/ui/placement_free.tres")
		$PlacementArrowSprite.set_self_modulate(Color.WHITE)
	
	arrow_node.global_position = new_current_platform.global_position
	
	if Input.is_action_just_pressed("mouse1") and !is_platform_occupied:
		_place_character(new_current_platform)


func _update_warning():
	var color: Color
	
	if tower_weight >= TOWER_WEIGHT_WARNING or tower_weight <= -TOWER_WEIGHT_WARNING:
		color = Color.RED
	else:
		color = Color.WHITE
	
	tower.set_modulate(
			lerp(tower.get_modulate(), color, 0.1)
	)


func _place_character(new_current_platform: Object) -> void:
	is_placing_character = false
	var new_char = character_scene.instantiate()
	new_current_platform.add_child(new_char)
	new_char.get_node("Sprites").get_child(current_char_type).show()
	
	_add_weight(new_char)
	define_new_character()
	
	score += 1


func _apply_weight() -> void:
	tower.rotation_degrees = lerp(tower.rotation_degrees, tower_weight, 0.02)
	
	if tower_weight >= TOWER_WEIGHT_OVERLOAD or tower_weight <= -TOWER_WEIGHT_OVERLOAD:
		_lose_game()


func _add_weight(char_node: Object):
	var layer_center_pos: Vector2 = char_node.get_node("../..").global_position # Get layer center pos
	var distance_from_center: float = char_node.global_position.distance_to(layer_center_pos) # Get distance from center in float
	
	var weight_to_add: float = pow((distance_from_center / 10) * current_char_weight, WEIGHT_EXP)
	
	if char_node.global_position.x > layer_center_pos.x: # Check character side and apply weight accordingly
		tower_weight += weight_to_add
	else:
		tower_weight -= weight_to_add


func _get_nearest_platform() -> Object:
	var platforms: Array = []
	
	for pos_node: Marker2D in current_platform.get_node("Positions").get_children():
		platforms.append(pos_node)
	
	platforms.sort_custom(sort_by_nearest)
	
	var nearest_platform: Marker2D = platforms[0]
	return nearest_platform


func sort_by_nearest(a, b):
	var mouse_pos = get_global_mouse_position()
	
	if mouse_pos.distance_to(a.global_position) < mouse_pos.distance_to(b.global_position):
		return true
	return false


func _win_game() -> void:
	game_over = true
	$Overlay.win()


func _lose_game() -> void:
	game_over = true
	$Overlay.lose()


func _on_new_character_button_pressed():
	if is_placing_character:
		return
	
	is_placing_character = true
	
