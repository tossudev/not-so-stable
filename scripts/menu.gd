extends Node2D

const TITLE_ROTATION_SPEED: float = 2.5
const TITLE_ROTATION_AMOUNT: float = 2.0

const TITLE_SCALE_AMOUNT: float = 0.13
const TITLE_SCALE_OFFSET: float = 1.0

const BUTTON_SCALE_NORMAL: float = 1.0
const BUTTON_SCALE_BIG: float = 1.2

const BUTTON_ANIM_SPEED: float = 0.6

# Time passed since start
var time: float = 0.0
var exiting_scene: bool = false

# Object references
@onready var title_node: Label = $Title


func _ready():
	# Connect button press signals for all buttons in scene.
	for button: Button in get_tree().get_nodes_in_group("Buttons"):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	
	Audio.get_node("Music").stop()


func _process(delta):
	time += delta
	_spin_title(delta)


func _spin_title(delta: float) -> void:
	# Update rotation and scale with a cosine wave for a smooth animation.
	var rotation_value: float = cos(
			time * TITLE_ROTATION_SPEED) * TITLE_ROTATION_AMOUNT
	var scale_value: float = (cos(
			time) * TITLE_SCALE_AMOUNT) + TITLE_SCALE_OFFSET
	
	title_node.rotation_degrees = rotation_value
	title_node.scale = Vector2(scale_value, scale_value)


func _on_button_start_pressed():
	exiting_scene = true
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_quit_pressed():
	exiting_scene = true
	get_tree().quit()


# Button scale animations

func _on_button_mouse_entered(button: Button):
	# Scale button to big size.
	var new_scale = Vector2(BUTTON_SCALE_BIG, BUTTON_SCALE_BIG)
	_do_scale_anim(button, new_scale)


func _on_button_mouse_exited(button: Button):
	# Scale button back to normal.
	var new_scale = Vector2(BUTTON_SCALE_NORMAL, BUTTON_SCALE_NORMAL)
	_do_scale_anim(button, new_scale)


func _do_scale_anim(node: Node, new_scale: Vector2):
	# Don't start tween if exiting scene.
	if exiting_scene:
		return
	
	var tween = get_tree().create_tween()
	
	# Tween scales node to new scale using the button animation speed and elastic easing.
	tween.tween_property(
			node, "scale",
			new_scale,
			BUTTON_ANIM_SPEED
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

