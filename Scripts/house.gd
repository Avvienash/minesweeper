extends AnimatableBody2D

@onready var explode: AnimatedSprite2D = $explode
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

var destroyed = false
var fade = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade:
		animated_sprite_2d.modulate.a = max(0,animated_sprite_2d.modulate.a - 1*delta)
		
	if animated_sprite_2d.modulate.a == 0:
		animated_sprite_2d.hide()
	
	
func _destroy():
	if destroyed == false:
		explode.show()
		explode.play()
		animated_sprite_2d.play()
		collision_shape_2d.disabled = true
		destroyed = true
		
	

func _on_explode_animation_finished() -> void:
	explode.hide()
	
func _on_animated_sprite_2d_animation_finished() -> void:
	timer.start()



func _on_timer_timeout() -> void:
	fade = true
