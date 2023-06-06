extends Area2D

var type = "b"
var base_damage = 1
var soul = [0, 0, 0, 0]
var hit = false
var health = 10
var ignore_invincible = false

var knockback_count = 0
var knockback_count_max = 4
var knockback = false

var knockback_velocity = Vector2.ZERO
var invincible = false

var heals = true
const base_drag = 10

var progress = [0, 0, 0, 0, 0]

signal sharp_shooter()
signal perilous_prize()

func _init():
    load_game()

func save_game():
    var f = File.new()
    f.open("user://savegame.save", File.WRITE)
    var data = { "progress": progress }
    # Store the save dictionary as a new line in the save file.
    f.store_line(to_json(data))
    f.close()
    
func load_game():
    var f = File.new()
    if not f.file_exists("user://savegame.save"):
        return
    f.open("user://savegame.save", File.READ)
    var data = parse_json(f.get_line())
    progress = data.progress
    f.close()

static func get_soul_component(soul, i):
    var sum = 0
    for j in soul:
        if j == i:
            sum += 1
    return sum

func knockback(hit_soul, hit_direction):
    var knockback_speed = 200 * (8 + get_soul_component(hit_soul, 0) + 2 * get_soul_component(hit_soul, 2) - 2 * get_soul_component(soul, 2))
    if knockback_speed > 0:
        knockback_velocity = knockback_speed * hit_direction
    else:
        # don't want this
        knockback_velocity = Vector2.ZERO
    knockback_count = knockback_count_max
    knockback = true
    var t = min(int(abs(health)) / int(10), 10)
    scale = Vector2(t, t)
    $AnimatedSprite.scale = Vector2(t, t)
    $CollisionShape2D.scale = Vector2(t, t)
    $AnimatedSprite.stop()
    $AnimatedSprite.animation = "hit"
    $AnimatedSprite.frame = 0
    $AnimatedSprite.play()

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
        knockback(hit_soul, hit_direction)
    elif damage < 0:
        heal(damage)
    
    if health <= 0:
        die()

static func get_stopping_speed(soul):
    return 62.5 * get_soul_component(soul, 3)
    
static func get_drag(soul):
    return base_drag + 30 * get_soul_component(soul, 2)

func _process(delta):
    if knockback && knockback_velocity.length() > 0:
        var displacement = knockback_velocity * delta
        position += displacement
        var knockback_direction = knockback_velocity / knockback_velocity.length()
        var drag = get_drag(soul)
        var t 
        t = knockback_velocity.x - drag * knockback_velocity.x * delta
        if sign(t) != sign(knockback_velocity.x):
            knockback_velocity.x = 0
        else:
            knockback_velocity.x = t
        
        t = knockback_velocity.y - drag * knockback_velocity.y * delta
        if sign(t) != sign(knockback_velocity.y):
            knockback_velocity.y = 0
        else:
            knockback_velocity.y = t
    else:
        position += knockback_velocity * delta
        var stopping_speed = get_stopping_speed(soul)
        if knockback_velocity.length() > stopping_speed:
            knockback_velocity -= get_drag(soul) * knockback_velocity * delta
        else:
            knockback_velocity = Vector2.ZERO

func die():
    if max_hit:
        progress[3] = 1
        save_game()
        print("sharp_shooter!")
        emit_signal("sharp_shooter")
    queue_free()

var max_hit = false

func heal(damage):
    var t
    #print("damage: %s" % damage)
    #print("health: %s" % health)
    t = min(int(abs(health)) / int(10), 8)
    if t >= 8:
        max_hit = true
        print ("max hit!")
    print("t = %s" % t)
    scale = Vector2(t, t)
    $AnimatedSprite.scale = Vector2(t, t)
    $CollisionShape2D.scale = Vector2(t, t)
    $AnimatedSprite.stop()
    $AnimatedSprite.animation = "heal"
    $AnimatedSprite.frame = 0
    $AnimatedSprite.play()


func _on_Trap_area_entered(area):
    if area and ("type" in area):
        if area.type == "b":
            take_damage(area.base_damage, area.soul, area.position.direction_to(position))
            area.hit = true
        elif area.type == "p":
            if max_hit && area.invincible and area.dragonfly_mode:
                if !progress[2]:
                    progress[2] = 1
                    save_game()
                    emit_signal("perilous prize")

