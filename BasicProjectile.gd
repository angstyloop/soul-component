extends Area2D

var direction
var speed
var angular_speed

var base_speed

var soul

func _init():
    direction = Vector2.ZERO
    speed = [0, 0, 0, 0]
    position = Vector2.ZERO
    angular_speed = 10
    base_speed = 2
    soul = [0, 0, 0, 0]

func _process(delta):
    position += base_speed * direction + (Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]) * delta
    rotation += angular_speed * delta
