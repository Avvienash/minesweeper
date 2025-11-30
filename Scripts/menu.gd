extends CanvasLayer
@onready var tile_map: Node = $"../TileMap"


func _ready() -> void:
	# Make sure menu is visible
	visible = true

func _on_easy_pressed():
	tile_map.loadGame("Easy")
	visible = false


func _on_medium_button_pressed() -> void:
	tile_map.loadGame("Medium")
	visible = false


func _on_hard_button_pressed() -> void:
	tile_map.loadGame("Hard")
	visible = false
