extends CanvasLayer

var game: Object # Reference to game manager


func _ready():
	game = get_node("/root/Game")


func _process(_delta):
	var score_text: String = str(game.score) + "/" + str(game.SCORE_GOAL)
	$Score.set_text(score_text)


func win() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($WinScreen, "modulate", Color.WHITE, 0.3)


func lose() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($LoseScreen, "modulate", Color.WHITE, 0.3)
