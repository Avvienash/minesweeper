extends Node

@onready var ground: TileMapLayer = $ground
@onready var foam: TileMapLayer = $foam
@onready var numbers: TileMapLayer = $numbers
@onready var player: CharacterBody2D = $"../Player"
@onready var camera_2d: Camera2D = $"../Player/Camera2D"
@onready var mine_timer: Timer = $mine_timer
@onready var wait_timer: Timer = $wait_timer
@onready var menu: CanvasLayer = $"../Menu"

@export var mine_scene: PackedScene
@export var house_scene: PackedScene


var difficulty_levels = {
	"Easy": {"rows": 9, "cols": 9, "mines": 10, "zoom": 1.05},
	"Medium": {"rows": 16, "cols": 16, "mines": 40, "zoom": 0.5},
	"Hard": {"rows": 24, "cols": 24, "mines": 99, "zoom": 0.4}
}

var rows = 10
var cols = 10
var mines = 10
var game_lost = false
var game_won = false
var mines_destroyed = -1
var sorted_mines = []
var zoom_out = 1.05

# 2D Array to hold mine positions
var mines_array = []
var mines_scene_array = []
var mines_uncovered_array = []


var tile_size = 64
const FOAM_ROCK_COUNT = 15
const FOAM_ROCK_DISTANCE = 3 # Max distance from edge to place foam rocks

var return_to_menu = false


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Zoom camera based out when gane is lost or won
	if game_lost or game_won:
		# pause the player movement
		player.pause_game()
		# move cmera to (center of map)
		# so get target position of center of map relavetive to player position
		var target_position = Vector2((rows * tile_size) / 2, (cols * tile_size) / 2)
		var direction = target_position - (player.position + camera_2d.position)
		var distance = direction.length()
		if distance > 10:
			direction = direction.normalized()
			camera_2d.position += direction * distance * delta * 0.4
		# zoom out camera
		if camera_2d.zoom.x > zoom_out:
			camera_2d.zoom -= Vector2(1,1) * delta * 0.4
			
		if (camera_2d.zoom.x <= zoom_out+0.01) and  (distance <= 11) and return_to_menu == true :
			menu.visible = true







func loadGame(difficulty: String):
	
	#get_tree().reload_current_scene()

	# Clear previous map scenes
	if mines_scene_array.size() > 0:
		for x in mines_scene_array.size():
			if mines_scene_array[x].size() > 0:
				for y in mines_scene_array[x].size():
					if mines_scene_array[x][y] != null:
						mines_scene_array[x][y].queue_free()
						mines_scene_array[x][y] = null

	# Clear the numbers layer
	numbers.clear()
	ground.clear()
	foam.clear()
	


	# Reset the entire tree
	mines_array = []
	mines_scene_array = []
	mines_uncovered_array = []
	sorted_mines = []

	

	var level = difficulty_levels[difficulty]
	rows = level["rows"]
	cols = level["cols"]
	mines = level["mines"]

	game_lost = false
	game_won = false
	mines_destroyed = -1
	return_to_menu = false
	camera_2d.position = Vector2(0,0)
	camera_2d.zoom = Vector2(1.7,1.7)
	zoom_out = level["zoom"]

	player.resume_game()
	
	setupMines()
	drawMap()
	initPlayer()


func initPlayer():
	var flag = false
	while not flag:
		var x = randi() % (rows-2) + 1
		var y = randi() % (cols-2) + 1 # Avoid edges
		if mines_array[x][y] == 0:
			player.position = Vector2(x * float(tile_size) + float(tile_size) / 2, y * float(tile_size) + float(tile_size) / 2)
			cellSelected(x,y)
			flag = true

		


func drawMap():
	ground.clear()
	foam.clear()
	for x in rows:
		for y in cols:
			# Check for corners
			if (x == 0 and y == 0):
				ground.set_cell(Vector2i(x,y),1,Vector2i(0,0),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif (x == 0 and y == cols - 1):
				ground.set_cell(Vector2i(x,y),1,Vector2i(0,2),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif (x == rows - 1 and y == 0):
				ground.set_cell(Vector2i(x,y),1,Vector2i(2,0),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif (x == rows - 1 and y == cols - 1):
				ground.set_cell(Vector2i(x,y),1,Vector2i(2,2),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			# Check for edges
			elif (x == 0):
				ground.set_cell(Vector2i(x,y),1,Vector2i(0,1),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif (x == rows - 1):
				ground.set_cell(Vector2i(x,y),1,Vector2i(2,1),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif (y == 0):
				ground.set_cell(Vector2i(x,y),1,Vector2i(1,0),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif (y == cols - 1):	
				ground.set_cell(Vector2i(x,y),1,Vector2i(1,2),0)
				foam.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			# Fill center
			else:
				ground.set_cell(Vector2i(x,y),1,Vector2i(1,1),0)

	# Add the Invisible Boundary Coordinate (1,4)
	for x in rows:
		ground.set_cell(Vector2i(x,cols),1,Vector2i(1,4),0)
		ground.set_cell(Vector2i(x,-1),1,Vector2i(1,4),0)
	for y in cols:
		ground.set_cell(Vector2i(rows,y),1,Vector2i(1,4),0)
		ground.set_cell(Vector2i(-1,y),1,Vector2i(1,4),0)
	# Add the Invisible Boundary Coordinate (4,1)
	ground.set_cell(Vector2i(rows,cols),1,Vector2i(4,1),0)
	ground.set_cell(Vector2i(-1,-1),1,Vector2i(4,1),0)
	ground.set_cell(Vector2i(rows,-1),1,Vector2i(4,1),0)
	ground.set_cell(Vector2i(-1,cols),1,Vector2i(4,1),0)

	# Add Foam Rocks at random postions around the map
	var rock_positions = []
	while rock_positions.size() < FOAM_ROCK_COUNT:
		var pos = Vector2i(
			randi() % (rows + FOAM_ROCK_DISTANCE * 2) - FOAM_ROCK_DISTANCE,
			randi() % (cols + FOAM_ROCK_DISTANCE * 2) - FOAM_ROCK_DISTANCE
		)
		if pos.x < -1 or pos.x > rows or pos.y < -1 or pos.y > cols:
			if not rock_positions.has(pos):
				rock_positions.append(pos)

	for pos in rock_positions: # id from 2-5
		foam.set_cell(pos,0,Vector2i(0,0),randi() % 4 + 2)


	for x in rows:
		for y in cols:
			if mines_array[x][y] == -1:
				mines_scene_array[x][y] = mine_scene.instantiate()
				mines_scene_array[x][y].position = Vector2(x * float(tile_size) + float(tile_size) / 2, y * float(tile_size) + float(tile_size) / 2)
				add_child(mines_scene_array[x][y])
			elif  mines_array[x][y] > 0:
				numbers.set_cell(Vector2i(x,y),mines_array[x][y],Vector2i(0,0),0) # Number tile
				mines_scene_array[x][y] = house_scene.instantiate()
				mines_scene_array[x][y].position = Vector2(x * float(tile_size) + float(tile_size) / 2, y * float(tile_size) + float(tile_size) / 2)
				add_child(mines_scene_array[x][y])
			elif mines_array[x][y] == 0:
				mines_scene_array[x][y] = house_scene.instantiate()
				mines_scene_array[x][y].position = Vector2(x * float(tile_size) + float(tile_size) / 2, y * float(tile_size) + float(tile_size) / 2)
				add_child(mines_scene_array[x][y])
			

func setupMines():
	resetMinesArray()
	resetSceneArray()
	resetUncoveredArray()
	var placed_mines = 0
	while placed_mines < mines:
		var x = randi() % rows
		var y = randi() % cols
		if mines_array[x][y] == 0:
			mines_array[x][y] = -1
			# Update adjacent cells
			# 1. Top
			if y > 0 and mines_array[x][y - 1] != -1:
				mines_array[x][y - 1] += 1
			# 2. Bottom
			if y < cols - 1 and mines_array[x][y + 1] != -1:
				mines_array[x][y + 1] += 1
			# 3. Left
			if x > 0 and mines_array[x - 1][y] != -1:
				mines_array[x - 1][y] += 1
			# 4. Right
			if x < rows - 1 and mines_array[x + 1][y] != -1:
				mines_array[x + 1][y] += 1
			# 5. Top-Left
			if x > 0 and y > 0 and mines_array[x - 1][y - 1] != -1:
				mines_array[x - 1][y - 1] += 1
			# 6. Top-Right
			if x < rows - 1 and y > 0 and mines_array[x + 1][y - 1] != -1:
				mines_array[x + 1][y - 1] += 1
			# 7. Bottom-Left
			if x > 0 and y < cols - 1 and mines_array[x - 1][y + 1] != -1:
				mines_array[x - 1][y + 1] += 1
			# 8. Bottom-Right
			if x < rows - 1 and y < cols - 1 and mines_array[x + 1][y + 1] != -1:
				mines_array[x + 1][y + 1] += 1
			placed_mines += 1



func resetMinesArray():
	mines_array = []
	for x in rows:
		mines_array.append([])
		for y in cols:
			mines_array[x].append(0)


func resetUncoveredArray():
	mines_uncovered_array = []
	for x in rows:
		mines_uncovered_array.append([])
		for y in cols:
			mines_uncovered_array[x].append(false)

func resetSceneArray():
	mines_scene_array = []
	for x in rows:
		mines_scene_array.append([])
		for y in cols:
			mines_scene_array[x].append(null)

func cellSelected(x,y) -> void:
	mines_uncovered_array[x][y] = true
	# first check if it's a mine
	if mines_array[x][y] == -1:
		
		# Handle game over logic here
		if mines_scene_array[x][y] != null:
			print("Hit mine at (", x, ",", y, ")")
			mines_scene_array[x][y]._destroy()

		gameOver()
	
	else:
		#print("Safe cell at (", x, ",", y, ") with value: ", mines_array[x][y])
		# Handle safe cell logic here
		if mines_scene_array[x][y] != null:
			mines_scene_array[x][y]._destroy()

		if mines_array[x][y] == 0:
			# Reveal adjacent cells recursively
			revealAdjacentCells(x, y)

		# Check for win condition here
		for i in rows:
			for j in cols:
				if mines_array[i][j] != -1 and not mines_uncovered_array[i][j]:
					return # Still safe cells left
		gameWon()

func gameWon():
	print("Congratulations! You've cleared all safe cells!")
	game_won = true
	wait_timer.start()

func gameOver():
	print("Game Over! You hit a mine.")
	game_lost = true
	# Reveal all mines based on disatnce from player
	var player_cell = Vector2i(int(player.position.x) / tile_size, int(player.position.y) / tile_size)
	var distances = []
	var mine_positions = []
	for x in rows:
		for y in cols:
			if mines_array[x][y] == -1:
				var dist = player_cell.distance_to(Vector2i(x,y))
				distances.append(dist)
				mine_positions.append(Vector2i(x,y))
	# Sort mines by distance
	sorted_mines = mine_positions.duplicate()
	sorted_mines.sort_custom(func(a, b):
		var dist_a = player_cell.distance_to(a)
		var dist_b = player_cell.distance_to(b)
		return dist_b - dist_a
	)
	
	# Reveal the first Mine and start the timer
	wait_timer.start()
	
func destroyMine():
	mines_destroyed += 1
	if mines_destroyed >= mines:
		return
	if mines_scene_array[sorted_mines[mines_destroyed].x][sorted_mines[mines_destroyed].y] == null:
		return
	mines_scene_array[sorted_mines[mines_destroyed].x][sorted_mines[mines_destroyed].y]._destroy()
	mine_timer.start()
	


func revealAdjacentCells(x, y) -> void:
	#print("Revealing adjacent cells for (", x, ",", y, ")")
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),				Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
	]

	for dir in directions:
		var new_x = x + dir.x
		var new_y = y + dir.y


		if new_x >= 0 and new_x < rows and new_y >= 0 and new_y < cols:

			# Only reveal if not already uncovered
			if mines_uncovered_array[new_x][new_y] ==  false:
				mines_uncovered_array[new_x][new_y] = true
				#print("Revealed cell at (", new_x, ",", new_y, ") with value: ", mines_array[new_x][new_y])

				
				if mines_scene_array[new_x][new_y] != null:
					mines_scene_array[new_x][new_y]._destroy()

				if mines_array[new_x][new_y] == 0:
					revealAdjacentCells(new_x, new_y)

	


func _on_mine_timer_timeout():
	if mines_destroyed < mines:
		destroyMine()
		print("Destroying mine number: ", mines_destroyed)
		if mines_destroyed >= mines:
			return_to_menu = true
			print("All mines destroyed, returning to menu. Mine numer: ", mines_destroyed)
		
func _on_wait_timer_timeout() -> void:
	if game_lost:
		destroyMine()
	elif game_won:
		return_to_menu = true

		
