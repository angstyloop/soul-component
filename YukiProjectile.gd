extends Area2D

var direction
var speed
var angular_speed

var base_speed = 0
var type = "y"
var soul
var base_damage
var held
var duration = 0
var free_count = -1
var first_run = true
var hit = false 
var radius
var parent
var ignore_invincible = false

static func get_soul_component(soul, i):
    var sum = 0
    for j in soul:
        if j == i:
            sum += 1
    return sum

func get_base_damage(soul):
    return 1 + floor(.5 * get_soul_component(soul, 0)) - floor(.5 * get_soul_component(soul, 1))
    
func get_base_speed(soul):
    return 100 + 50 * max(0, (get_soul_component(soul, 1) + get_soul_component(soul, 3) - get_soul_component(soul, 2)))

func _init():
    direction = Vector2.ZERO
    speed = 0
    position = Vector2.ZERO
    angular_speed = 10
    base_damage = 1
    held = true
    
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
        parent = get_parent().get_node("Yuki")
        if parent:
            soul = parent.soul
            base_speed = get_base_speed(parent.soul)
            base_damage = get_base_damage(parent.soul)
            # NPC's are always fixed frame, so this parent.position term
            # is here
            position = parent.position + parent.direction * .5 * parent.radius
            radius = parent.projectile_radius
            held = false
            
    if !held:
        var displacement = (base_speed + speed) * direction * delta
        position += displacement
        var scale_delta = displacement.length() * radius / 1000
        scale.x += delta
        scale.y += delta
        radius *= scale.x
        var speed_delta = - (1 - .5 / scale_delta)
        speed = max(.5, speed + speed_delta)
        
    rotation += angular_speed * delta
