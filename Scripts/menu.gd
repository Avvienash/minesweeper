extends CanvasLayer

# Global variable to store difficulty level
var difficulty: String = "easy"

func _ready() -> void:
	# Make sure menu is visible
	visible = true

func _on_easy_pressed() -> void:
	difficulty = "easy"
	load_game()

func _on_medium_pressed() -> void:
	difficulty = "medium"
	load_game()

func _on_hard_pressed() -> void:
	difficulty = "hard"
	load_game()

func load_game() -> void:
	# Store difficulty in a global/autoload or pass it to the game scene
	# For now, we'll use a global variable approach
	GameSettings.difficulty = difficulty
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	# Quit the application
	get_tree().quit()
