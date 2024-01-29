extends CanvasLayer

 # Reference to game manager object
var game: Object


func _ready():
	# Set reference to game manager object.
	game = get_node("/root/Game")


func _process(_delta):
	# Set score text to say [SCORE]/[GOAL].
	var score_text: String = str(game.score) + "/" + str(game.SCORE_GOAL)
	$Score.set_text(score_text)


func win() -> void:
	# Fade in win screen.
	var tween = get_tree().create_tween()
	tween.tween_property($WinScreen, "modulate", Color.WHITE, 0.3)


func lose() -> void:
	# Fade in lose screen.
	var tween = get_tree().create_tween()
	tween.tween_property($LoseScreen, "modulate", Color.WHITE, 0.3)
