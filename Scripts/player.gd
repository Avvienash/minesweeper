extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_map: Node = $"../TileMap"

const speed = 100

# State
var direction = "null"
var attacking = false
var running = false
var pause = false

# Attackable Towers
var isleftTower = null
var isrightTower = null
var isupTower = null
var isdownTower = null
var isdownleftTower = null
var isdownrightTower = null
var isupleftTower = null
var isuprightTower = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func pause_game():
	pause = true

func resume_game():
	pause = false

func _physics_process(delta):
	if pause:
		return

	# Movement Input
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("right"):
		velocity.x += 1
		animated_sprite_2d.flip_h = false
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		animated_sprite_2d.flip_h = true
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		
	# Get Direction
	if velocity.x > 0 and velocity.y == 0:
		direction = "right"
	elif velocity.x < 0 and velocity.y == 0:
		direction = "left"
	elif velocity.y > 0 and velocity.x == 0:
		direction = "down"
	elif velocity.y < 0 and velocity.x == 0:
		direction = "up"
	elif velocity.x > 0 and velocity.y > 0:
		direction = "downright"
	elif velocity.x < 0 and velocity.y > 0:
		direction = "downleft"
	elif velocity.x > 0 and velocity.y < 0:
		direction = "upright"
	elif velocity.x < 0 and velocity.y < 0:
		direction = "upleft"
	
	# set walking bool
	if velocity.length() > 0:
		running = true
	else:
		running = false

	
	# States Animation
	if Input.is_action_pressed("attack") and (attacking == false):
		if (direction == "right" or direction == "left"):
			animated_sprite_2d.animation = "attack_right"
		elif (direction == "down"):
			animated_sprite_2d.animation = "attack_down"
		elif (direction == "up"):
			animated_sprite_2d.animation = "attack_up"
		elif (direction == "downright" or direction == "downleft"):
			animated_sprite_2d.animation = "attack_down_right"
		elif (direction == "upright" or direction == "upleft"):
			animated_sprite_2d.animation = "attack_up_right"
		attacking = true
		
	elif (attacking == false):
		if (running == true):
			animated_sprite_2d.animation = "run"
			velocity = velocity.normalized() * speed
			position += velocity * delta
		else:
			if (direction == "right" or direction == "left"):
				animated_sprite_2d.animation = "defend_right"
			elif (direction == "down"):
				animated_sprite_2d.animation = "defend_down"
			elif (direction == "up"):
				animated_sprite_2d.animation = "defend_up"
			elif (direction == "downright" or direction == "downleft"):
				animated_sprite_2d.animation = "defend_down_right"
			elif (direction == "upright" or direction == "upleft"):
				animated_sprite_2d.animation = "defend_up_right"
			elif (direction == "null"):
				animated_sprite_2d.animation = "idle"
	
	# On animation chnage =>  play
	if animated_sprite_2d.animation_changed:
		animated_sprite_2d.play()

	# Attack Finish (check if animation name contains "attack" and set attacking to false)
	if animated_sprite_2d.animation_finished  and animated_sprite_2d.animation.find("attack") != -1:
		attacking = false
		

	# Damage Towers
	# left:
	if ( isleftTower != null ) and (animated_sprite_2d.animation == "attack_right"	) and (animated_sprite_2d.flip_h == true):
		var pos =  Vector2i(int(position.x / 64) - 1, int(position.y / 64))
		tile_map.cellSelected(pos.x,pos.y)

	# right:
	if ( isrightTower != null ) and (animated_sprite_2d.animation == "attack_right"	) and (animated_sprite_2d.flip_h == false):
		var pos =  Vector2i(int(position.x / 64) + 1, int(position.y / 64))
		tile_map.cellSelected(pos.x,pos.y)
	# up:
	if ( isupTower != null ) and (animated_sprite_2d.animation == "attack_up"	):
		var pos =  Vector2i(int(position.x / 64), int(position.y / 64) - 1)
		tile_map.cellSelected(pos.x,pos.y)
	# down:
	if ( isdownTower != null ) and (animated_sprite_2d.animation == "attack_down"):
		var pos =  Vector2i(int(position.x / 64), int(position.y / 64) + 1)
		tile_map.cellSelected(pos.x,pos.y)
	# upleft:
	if ( isupleftTower != null ) and (animated_sprite_2d.animation == "attack_up_right") and (animated_sprite_2d.flip_h == true):
		var pos =  Vector2i(int(position.x / 64) - 1, int(position.y / 64) - 1)
		tile_map.cellSelected(pos.x,pos.y)
	# upright:
	if ( isuprightTower != null ) and (animated_sprite_2d.animation == "attack_up_right") and (animated_sprite_2d.flip_h == false):
		var pos =  Vector2i(int(position.x / 64) + 1, int(position.y / 64) - 1)
		tile_map.cellSelected(pos.x,pos.y)
	# downleft:
	if ( isdownleftTower != null ) and (animated_sprite_2d.animation == "attack_down_right") and (animated_sprite_2d.flip_h == true):
		var pos =  Vector2i(int(position.x / 64) - 1, int(position.y / 64) + 1)
		tile_map.cellSelected(pos.x,pos.y)
	# downright:
	if ( isdownrightTower != null ) and (animated_sprite_2d.animation == "attack_down_right") and (animated_sprite_2d.flip_h == false):
		var pos =  Vector2i(int(position.x / 64) + 1, int(position.y / 64) + 1)
		tile_map.cellSelected(pos.x,pos.y)
	
	# Move the player
	move_and_slide()
		

func _on_left_body_entered(body: Node2D):
	isleftTower = body

func _on_left_body_exited(_body: Node2D):
	isleftTower = null

func _on_right_body_entered(body: Node2D):
	isrightTower = body	

func _on_right_body_exited(_body: Node2D):
	isrightTower = null

func _on_up_body_entered(body: Node2D):
	isupTower = body

func _on_up_body_exited(_body: Node2D):
	isupTower = null

func _on_down_body_entered(body: Node2D):
	isdownTower = body

func _on_down_body_exited(_body: Node2D):
	isdownTower = null


func _on_down_right_body_entered(body: Node2D) -> void:
	isdownrightTower = body


func _on_down_right_body_exited(_body: Node2D) -> void:
	isdownrightTower = null


func _on_down_left_body_entered(body: Node2D) -> void:
	isdownleftTower = body


func _on_down_left_body_exited(_body: Node2D) -> void:
	isdownleftTower = null


func _on_up_right_body_entered(body: Node2D) -> void:
	isuprightTower = body


func _on_up_right_body_exited(_body: Node2D) -> void:
	isuprightTower = null


func _on_up_left_body_entered(body: Node2D) -> void:
	isupleftTower = body


func _on_up_left_body_exited(_body: Node2D) -> void:
	isupleftTower = null
