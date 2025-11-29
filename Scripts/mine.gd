extends AnimatableBody2D

@onready var explode: AnimatedSprite2D = $explode
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var destroyed = false

func _ready() -> void:
	explode.hide()


func _destroy():
	print("destroy")
	if destroyed == false:
		destroyed = true
		animated_sprite_2d.play()
		collision_shape_2d.disabled = true
		animated_sprite_2d.hide()
		explode.show()
		explode.play()


func _on_explode_animation_finished() -> void:
	explode.hide()
