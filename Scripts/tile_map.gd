extends Node

@onready var ground: TileMapLayer = $ground
@onready var foam: TileMapLayer = $foam
@onready var numbers: TileMapLayer = $numbers
@onready var player: CharacterBody2D = $"../Player"
@onready var camera_2d: Camera2D = $"../Player/Camera2D"

@export var mine_scene: PackedScene
@export var house_scene: PackedScene


var rows = 10
var cols = 10
var mines = 10

# 2D Array to hold mine positions
var mines_array = []
var mines_scene_array = []
var mines_uncovered_array = []


var tile_size = 64

const FOAM_ROCK_COUNT = 15
const FOAM_ROCK_DISTANCE = 3 # Max distance from edge to place foam rocks

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupMines()
	drawMap()
	# Position player at random location within the map bounds
	initPlayer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

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

	# Debug print
	for row in mines_array:
		print(row)

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
		print("Game Over! Stepped on a mine at (", x, ",", y, ")")
		
		# Handle game over logic here
		if mines_scene_array[x][y] != null:
				mines_scene_array[x][y]._destroy()
	else:
		print("Safe cell at (", x, ",", y, ") with value: ", mines_array[x][y])
		# Handle safe cell logic here
		if mines_scene_array[x][y] != null:
			mines_scene_array[x][y]._destroy()

		if mines_array[x][y] == 0:
			# Reveal adjacent cells recursively
			revealAdjacentCells(x, y)

func revealAdjacentCells(x, y) -> void:
	print("Revealing adjacent cells for (", x, ",", y, ")")
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
				print("Revealed cell at (", new_x, ",", new_y, ") with value: ", mines_array[new_x][new_y])

				
				if mines_scene_array[new_x][new_y] != null:
					mines_scene_array[new_x][new_y]._destroy()

				if mines_array[new_x][new_y] == 0:
					revealAdjacentCells(new_x, new_y)

	
