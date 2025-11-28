extends Node

@onready var ground: TileMapLayer = $ground
@onready var foam: TileMapLayer = $foam
@onready var buildings: TileMapLayer = $buildings
@onready var player: CharacterBody2D = $"../Player"

var rows = 10
var cols = 10
var mines = 10

# 2D Array to hold mine positions
var mines_array = []


var tile_size = 64

const FOAM_ROCK_COUNT = 15
const FOAM_ROCK_DISTANCE = 3 # Max distance from edge to place foam rocks

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	drawMap()
	player.position = Vector2(randf() * rows * tile_size, randf() * cols * tile_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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


func setupMines():
	pass

