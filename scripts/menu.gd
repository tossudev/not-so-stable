extends Node2D

const BUTTON_SCALE_NORMAL: float = 1.0
const BUTTON_SCALE_BIG: float = 1.2

const BUTTON_ANIM_SPEED: float = 0.6

var exiting_scene: bool = false


func _ready():
	# Connect button press signals for all buttons in scene.
	for button: Button in get_tree().get_nodes_in_group("Buttons"):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	
	Audio.get_node("Music").stop()


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

