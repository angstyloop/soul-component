extends Area2D

var direction
var speed
var angular_speed
var ignore_invincible = false

var base_speed
var type = "b"
var soul
var base_damage
var held
var duration = 0
var free_count = -1
var first_run = true
var hit = false

static func get_soul_component(soul, i):
    var sum = 0
    for j in soul:
        if j == i:
            sum += 1
    return sum

static func get_base_damage(soul):
    return 1 + floor(.5 * get_soul_component(soul, 0)) - floor(.5 * get_soul_component(soul, 1))
    
static func get_base_speed(soul):
    return 100 + 50 * max(0, (get_soul_component(soul, 1) + get_soul_component(soul, 3) - get_soul_component(soul, 2)))

func _init():
    direction = Vector2.ZERO
    base_speed = 100
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
            var radius = parent.get_node("CollisionShape2D").shape.radius
            if "soul" in parent:
                base_speed = get_base_speed(parent.soul)
                base_damage = get_base_damage(parent.soul)
                if parent.animation_prefix == "cloud":
                    position = - 3.4 * radius * parent.direction
                else:
                    position = parent.direction * 2 * (radius + $CollisionShape2D.shape.radius)
    else:
        position += (base_speed + speed) * direction * delta
    rotation += angular_speed * delta
