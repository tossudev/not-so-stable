extends Node2D

# Texture sizes, used to repeat textures infinitely.
const BG_TEXTURE_WIDTH: int = 288

# Speed values for different layers
const CLOUDS_SPEED: float = -10.0
const CLOUDS_FG_SPEED: float = -5.0
const WATER_SPEED: float = -15.0
const WATER_FG_SPEED: float = -20.0

# Node references
var clouds: Object
var clouds_fg: Object
var water: Object
var water_fg: Object

var moving_objects: Array = []


func _ready():
	_init_nodes()


func _process(delta):
	_update_background(delta)


func _init_nodes() -> void:
	# Set all node references
	clouds = $Clouds
	clouds_fg = $CloudsFG
	water = $Water
	water_fg = $WaterFG
	
	# Add moving objects to a list
	moving_objects = [
		clouds,
		clouds_fg,
		water,
		water_fg,
	]


func _update_background(delta: float) -> void:
	# Move all layers at their own speeds.
	clouds.position.x += CLOUDS_SPEED * delta
	clouds_fg.position.x += CLOUDS_FG_SPEED * delta
	
	water.position.x += WATER_SPEED * delta
	water_fg.position.x += WATER_FG_SPEED * delta
	
	# When layer x-position exceeds its own width, set layer back to 0 on the x-axis.
	for bg_node in moving_objects:
		if bg_node.position.x <= -BG_TEXTURE_WIDTH:
			bg_node.position.x = 0
