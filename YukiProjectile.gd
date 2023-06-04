extends Area2D

var direction
var speed
var angular_speed

var base_speed
var type = "b"
var soul
var base_damage
var held
var duration = 0
var free_count = -1
var first_run = true
var hit = false

func _init():
    direction = Vector2.ZERO
    base_speed = 2
    speed = 0
    position = Vector2.ZERO
    angular_speed = 10
    soul = [0, 1, 2, 3]
    base_damage = 1
    held = false
    
func _process(delta):
    if first_run:
        if duration > 0:
            free_count = duration
        first_run = false
        
    if duration > 0:
        if free_count > 0:
            free_count -= 1
        else:
            get_parent().remove_child(self)
            queue_free()
            
    if held:
        var parent = get_parent()
        if parent and ("direction" in parent):
            var radius = $CollisionShape2D.shape.radius
            position = parent.direction * 2 * (radius + get_node("CollisionShape2D").shape.radius)
    else:
        #print(base_speed)
        #print(direction)
        #print(speed)
        #print(delta)
        position += (base_speed + speed) * direction * delta
    rotation += angular_speed * delta
