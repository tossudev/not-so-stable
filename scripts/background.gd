extends Node2D

const BG_TEXTURE_WIDTH: int = 288 # Used for repeating textures infinitely
const CLOUDS_SPEED: float = -10.0
const CLOUDS_FG_SPEED: float = -5.0
const WATER_SPEED: float = -15.0
const WATER_FG_SPEED: float = -20.0


var clouds: Object
var clouds_fg: Object
var water: Object
var water_fg: Object

var moving_objects: Array = []


func _ready():
	clouds = $Clouds
	clouds_fg = $CloudsFG
	water = $Water
	water_fg = $WaterFG
	
	moving_objects = [
		clouds,
		clouds_fg,
		water,
		water_fg,
	]


func _process(delta):
	_update_background(delta)


func _update_background(delta: float) -> void:
	clouds.position.x += CLOUDS_SPEED * delta
	clouds_fg.position.x += CLOUDS_FG_SPEED * delta
	
	water.position.x += WATER_SPEED * delta
	water_fg.position.x += WATER_FG_SPEED * delta
	
	for bg_node in moving_objects:
		if bg_node.position.x <= -BG_TEXTURE_WIDTH:
			bg_node.position.x = 0
