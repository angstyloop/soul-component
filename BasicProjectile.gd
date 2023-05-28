extends Area2D

var direction
var speed

func _init():
    direction = Vector2.ZERO
    speed = 100
    position = Vector2.ZERO

func _process(delta):
    position += speed * delta * direction
    
