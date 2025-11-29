extends AnimatableBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var destroyed = false

func _destroy():
	print("Destroy)")
	if destroyed == false:
		animated_sprite_2d.play()
		collision_shape_2d.disabled = true
		destroyed = true
		animated_sprite_2d.hide()
		
	
