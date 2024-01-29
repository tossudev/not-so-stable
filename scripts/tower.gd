extends Node2D

const SWAY_TIME: float = 8.0
const SWAY_AMOUNT: float = 2.0

var time: float = 0.0 # Time passed since start
var game: Object # Reference to game manager


func _ready():
	_init_platforms()
	game = get_node("/root/Game")


func _process(delta):
	time += delta
	
	_update_sway(delta)


func _init_platforms() -> void:
	for platform: Area2D in $Platforms.get_children():
		platform.mouse_entered.connect(_on_platform_mouse_entered.bind(platform))
		platform.mouse_exited.connect(_on_platform_mouse_exited.bind(platform))


func _on_platform_mouse_entered(platform: Area2D):
	game.mouse_on_platform = true
	game.current_platform = platform


func _on_platform_mouse_exited(_platform: Area2D):
	game.mouse_on_platform = false


func _update_sway(delta: float) -> void:
	position.y += (cos(SWAY_AMOUNT * time) / SWAY_TIME) * (delta * 60)
