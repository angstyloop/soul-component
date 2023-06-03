extends Area2D

var type = "b"
var base_damage = 1
var soul = [0, 0, 0, 0]
var hit = false
var health = 10

var knockback_count = 0
var knockback_count_max = 4
var knockback = false
var knockback_animation_started = false
var knockback_velocity = Vector2.ZERO
var invincible = false

var heals = false
var drag = 2
const base_drag = 2

static func get_soul_component(soul, i):
    var sum = 0
    for j in soul:
        if j == i:
            sum += 1
    return sum

func knockback(hit_soul, hit_direction):
    var knockback_speed = 200 * (8 + get_soul_component(hit_soul, 0) + get_soul_component(hit_soul, 2) - 2 * get_soul_component(soul, 2))
    if knockback_speed > 0:
        knockback_velocity = knockback_speed * hit_direction
    else:
        # don't want this
        knockback_velocity = Vector2.ZERO
    knockback_count = knockback_count_max
    knockback = true
    $AnimatedSprite.play("hit")

func _on_Beats_timeout():
    if knockback:
        if knockback_count > 0:
            knockback_count -= 1
        else:
            knockback = false
    
    #if attack_cooldown_counter > 0:
        #attack_cooldown_counter -= 1

func take_damage(hit_base_damage, hit_soul, hit_direction):
    if invincible:
        return
        
    var damage = hit_base_damage
    
    for i in hit_soul:
        if i == 3:
            pass
        else:
            var weakness
            if i == 0:
                weakness = 2
            else:
                weakness = i - 1
                
            for j in soul:
                if j == weakness:
                    damage += 1
    if heals:
        for i in hit_soul:
            if i == 3:
                pass
            else:
                var strength
                if i == 2:
                    strength = 0
                else:
                    strength = i + 1
                    
                for j in soul:
                    if j == strength:
                        damage -= 1
    health -= damage
    
    if damage > 0:
        print("knockback. %s remains." % health)
        knockback(hit_soul, hit_direction)
    else:
        print("heal")
        heal(damage)
    
    if health <= 0:
        die()

static func get_stopping_speed(soul):
    return 62.5 * get_soul_component(soul, 3)
    
static func get_drag(soul):
    return base_drag + 3 * get_soul_component(soul, 2)

func _process(delta):
    if knockback && knockback_velocity.length() > 0:
        var displacement = knockback_velocity * delta
        position += displacement
        var knockback_direction = knockback_velocity / knockback_velocity.length()
        var drag = get_drag(soul)
        knockback_velocity += drag * delta * knockback_direction
    else:
        position += knockback_velocity * delta
        var stopping_speed = get_stopping_speed(soul)
        if knockback_velocity.length() > stopping_speed:
            knockback_velocity -= drag * knockback_velocity * delta
        else:
            knockback_velocity = Vector2.ZERO

func die():
    queue_free()

func heal(damage):
    health += damage
    if health > 10:
        scale = health / 10
    $AnimatedSprite.play("heal")

func _on_Trap_area_entered(area):
    if area and ("type" in area) and area.type == "b":
        take_damage(area.base_damage, area.soul, area.position.direction_to(position))
        area.hit = true

