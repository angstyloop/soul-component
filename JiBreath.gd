extends Area2D

var direction
var speed
var angular_speed
var acceleration

var type = "b"

func _init():
    direction = Vector2.ZERO
    position = Vector2.ZERO
    speed = 4
    angular_speed = 0
    acceleration = 0
    
func _process(delta):            
    if speed <= 0:
        return
        
    position += speed * direction * delta
    rotation += angular_speed * delta
    speed += acceleration * delta
    
    if speed < 0:
        speed = 0

func _on_AnimatedSprite_animation_finished():
    get_parent().remove_child(self)
    queue_free()
