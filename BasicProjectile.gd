extends Area2D

var direction
var speed
var angular_speed

var base_speed
var type = "b"
var soul
var base_damage

func _init():
    direction = Vector2.ZERO
    base_speed = 2
    speed = [0, 0, 0, 0]
    position = Vector2.ZERO
    angular_speed = 10
    soul = [0, 1, 2, 3]
    base_damage = 1

func _process(delta):
    position += base_speed * direction + (Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]) * delta
    rotation += angular_speed * delta
