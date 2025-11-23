extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const speed = 100
var attacking = false

var isleftTower = null
var isrightTower = null
var isupTower = null
var isbottomTower = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _physics_process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
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
		
	# check if attack animation is playing
	
	
	# States Animation
	if Input.is_action_pressed("attack") and (attacking == false):
		if ( Input.is_action_pressed("right") or Input.is_action_pressed("left")):
			attacking = true
			animated_sprite_2d.animation = "attack_right"
			animated_sprite_2d.play()
		elif Input.is_action_pressed("down"):
			attacking = true
			animated_sprite_2d.animation = "attack_down"
			animated_sprite_2d.play()
		elif Input.is_action_pressed("up"):
			attacking = true
			animated_sprite_2d.animation = "attack_up"
			animated_sprite_2d.play()
	elif (attacking == false):
		if velocity.length() > 0:
			animated_sprite_2d.animation = "run"
			velocity = velocity.normalized() * speed
			position += velocity * delta
		else:
			animated_sprite_2d.animation = "idle"
			
			
	if (animated_sprite_2d.animation == "attack_down" or animated_sprite_2d.animation == "attack_right"	or animated_sprite_2d.animation == "attack_up") 		and  animated_sprite_2d.animation_finished:
		attacking = false
		
	if ( isleftTower != null ) and (animated_sprite_2d.animation == "attack_right"	) and (animated_sprite_2d.flip_h == true):
		isleftTower._destroy()
		
	if ( isrightTower != null ) and (animated_sprite_2d.animation == "attack_right"	) and (animated_sprite_2d.flip_h == false):
		isrightTower._destroy()
		
	if ( isupTower != null ) and (animated_sprite_2d.animation == "attack_up"	):
		isupTower._destroy()
		
	if ( isbottomTower != null ) and (animated_sprite_2d.animation == "attack_down"):
		isbottomTower._destroy()
	


	move_and_slide()
		
		
		
	
func _on_left_attack_zone_body_entered(body: Node2D):
	isleftTower = body
	
func _on_left_attack_zone_body_exited(body: Node2D) -> void:
	isleftTower = null

func _on_right_attack_zone_body_entered(body: Node2D):
	isrightTower = body
	
func _on_right_attack_zone_body_exited(body: Node2D) -> void:
	isrightTower = null
	
func _on_up_attack_zone_body_entered(body: Node2D):
	isupTower = body
	
func _on_up_attack_zone_body_exited(body: Node2D) -> void:
	isupTower = null
	
func _on_bottom_attack_zone_body_entered(body: Node2D):
	isbottomTower = body
	
func _on_bottom_attack_zone_body_exited(body: Node2D) -> void:
	isbottomTower = null
