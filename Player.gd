extends Area2D

var first_run
var window_size
var speed
var spin_speed
var direction
var speed_sum
var soul
var initial_speed
var speed_limit
var initial_acceleration
var acceleration_growth
var drag
var stopping_speed

var last_delta
var top_boundary_position
var right_boundary_position
var bottom_boundary_position
var left_boundary_position

var health
var max_health
var armor
var invincible

var fire_shield = null
var fire_shield_counter
var fire_shield_cooldown_counter
var attack_cooldown_counter

var animation_prefix

var type = "p"

var special = {}

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const len_soul = 4
const base_drag = 4
const BasicProjectile = preload("res://BasicProjectile.tscn")
const basic_projectiles = {"0_0_0_0": preload("res://basic_projectile_0_0_0_0.png"), "0_0_0_1": preload("res://basic_projectile_0_0_0_1.png"), "0_0_0_2": preload("res://basic_projectile_0_0_0_2.png"), "0_0_0_3": preload("res://basic_projectile_0_0_0_3.png"), "0_0_1_1": preload("res://basic_projectile_0_0_1_1.png"), "0_0_1_2": preload("res://basic_projectile_0_0_1_2.png"), "0_0_1_3": preload("res://basic_projectile_0_0_1_3.png"), "0_0_2_2": preload("res://basic_projectile_0_0_2_2.png"), "0_0_2_3": preload("res://basic_projectile_0_0_2_3.png"), "0_0_3_3": preload("res://basic_projectile_0_0_3_3.png"), "0_1_1_1": preload("res://basic_projectile_0_1_1_1.png"), "0_1_1_2": preload("res://basic_projectile_0_1_1_2.png"), "0_1_1_3": preload("res://basic_projectile_0_1_1_3.png"), "0_1_2_2": preload("res://basic_projectile_0_1_2_2.png"), "0_1_2_3": preload("res://basic_projectile_0_1_2_3.png"), "0_1_3_3": preload("res://basic_projectile_0_1_3_3.png"), "0_2_2_2": preload("res://basic_projectile_0_2_2_2.png"), "0_2_2_3": preload("res://basic_projectile_0_2_2_3.png"), "0_2_3_3": preload("res://basic_projectile_0_2_3_3.png"), "0_3_3_3": preload("res://basic_projectile_0_3_3_3.png"), "1_1_1_1": preload("res://basic_projectile_1_1_1_1.png"), "1_1_1_2": preload("res://basic_projectile_1_1_1_2.png"), "1_1_1_3": preload("res://basic_projectile_1_1_1_3.png"), "1_1_2_2": preload("res://basic_projectile_1_1_2_2.png"), "1_1_2_3": preload("res://basic_projectile_1_1_2_3.png"), "1_1_3_3": preload("res://basic_projectile_1_1_3_3.png"), "1_2_2_2": preload("res://basic_projectile_1_2_2_2.png"), "1_2_2_3": preload("res://basic_projectile_1_2_2_3.png"), "1_2_3_3": preload("res://basic_projectile_1_2_3_3.png"), "1_3_3_3": preload("res://basic_projectile_1_3_3_3.png"), "2_2_2_2": preload("res://basic_projectile_2_2_2_2.png"), "2_2_2_3": preload("res://basic_projectile_2_2_2_3.png"), "2_2_3_3": preload("res://basic_projectile_2_2_3_3.png"), "2_3_3_3": preload("res://basic_projectile_2_3_3_3.png"), "3_3_3_3": preload("res://basic_projectile_3_3_3_3.png")}
const FireShield = preload("res://FireShield.tscn")

signal soul_switch(soul)
signal player_attack(soul)
signal player_hit(new_health, damage)

func _init():
    first_run = true
    
    window_size = OS.get_real_window_size()
    #position = Vector2(window_size[0] / 2, window_size[1] / 2)
    
    soul = [0, 0, 0, 0]    
    speed = [0, 0, 0, 0]
    
    direction = Vector2.ZERO
    
    max_health = 10
    health = max_health
    
    invincible = false
    
    fire_shield_counter = 0
    fire_shield_cooldown_counter = 0
    attack_cooldown_counter = 0
    
    last_delta = 100
    top_boundary_position = 0
    right_boundary_position = 450 * 2
    bottom_boundary_position = 450 * 2
    left_boundary_position = 0
    
    update_stats(soul)

func update_stats(soul):
    spin_speed = get_spin_speed(soul)
    drag = get_drag(soul)
    initial_speed = get_initial_speed(soul)
    speed_limit = get_speed_limit(soul)
    initial_acceleration = get_initial_acceleration(soul)
    acceleration_growth = get_acceleration_growth(soul)
    stopping_speed = get_stopping_speed(soul)
    
static func get_soul_component(soul, i):
    var sum = 0
    for j in soul:
        if j == i:
            sum += 1
    return sum

static func get_spin_speed(soul):
    return 4 * get_soul_component(soul, 3)

static func get_drag(soul):
    return base_drag + 3 * get_soul_component(soul, 2)

static func get_initial_speed(soul):
    return 1 * (1 + get_soul_component(soul, 3))

static func get_speed_limit(soul):
    return 200 * (1 + get_soul_component(soul, 3))

static func get_initial_acceleration(soul):
    return 1000 * (1 + get_soul_component(soul, 3))

static func get_acceleration_growth(soul):
    return 5 * get_soul_component(soul, 3)

static func get_armor(soul):
    return 1 * get_soul_component(soul, 2)
    
static func get_regen(soul):
    return 1 * get_soul_component(soul, 1)

static func get_stopping_speed(soul):
    return 62.5 * get_soul_component(soul, 3)

func soul_push_back(soul_index):
    for i in len_soul - 1:
        soul[i] = soul[i + 1]
    soul[len_soul - 1] = soul_index
    emit_signal("soul_switch", soul)
    update_stats(soul)  

func stand(_delta):
    animation_prefix = "stand"
    
func move(direction_index, delta):
    #print("move")
    if direction_index < 4:
        #print(direction_index)
        #print(position)
        if speed[direction_index] == 0:
            speed[direction_index] = initial_speed
        
        speed[direction_index]  += initial_acceleration * exp(acceleration_growth * delta) * delta
        
        if speed[direction_index]  > speed_limit:
            speed[direction_index]  = speed_limit
    
    elif direction_index == 4:
        # left and up
        if speed[3] == 0 and speed[0] == 0:
            var t = initial_speed / sqrt(2)
            speed[3] = t
            speed[0] = t
        var t = initial_acceleration * exp(acceleration_growth * delta) * delta / sqrt(2)
        speed[3] += t
        speed[0] += t
    # diagonals

    elif direction_index == 5:
        # up and right
        if speed[0] == 0 and speed[1] == 0:
            var t = initial_speed / sqrt(2)
            speed[0] = t
            speed[1] = t
        var t = initial_acceleration * exp(acceleration_growth * delta) * delta / sqrt(2)
        speed[0] += t
        speed[1] += t

    elif direction_index == 6:
        # right and down
        if speed[1] == 0 and speed[2] == 0:
            var t = initial_speed / sqrt(2)
            speed[1] = t
            speed[2] = t
        var t = initial_acceleration * exp(acceleration_growth * delta) * delta / sqrt(2)
        speed[1] += t
        speed[2] += t
        
    elif direction_index == 7:
        # down and left
        if speed[2] == 0 and speed[3] == 0:
            var t = initial_speed / sqrt(2)
            speed[2] = t
            speed[3] = t
        var t = initial_acceleration * exp(acceleration_growth * delta) * delta / sqrt(2)
        speed[2] += t
        speed[3] += t
    
    var v = Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]
    
    if v.length() > 0.0001:
        direction = v / v.length()
    
    if get_soul_component(soul, 3) == 4:
        animation_prefix = "cloud"
        rotation = PI / 2 - direction.angle_to(directions[2])
    else:
        animation_prefix = "walk"
        rotation = 0
        
    var children = get_children()
    var irla = get_node("BasicProjectile")
    if irla:
        irla.speed = [0, 0, 0, 0]
        irla.base_speed = 0
        irla.position_fixed = true
        irla.get_node("CollisionShape2D").disabled = true
        irla.position = direction * 2 * get_node("CollisionShape2D").shape.radius
        irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)

    #print(direction)

func get_basic_projectile_texture(soul):
    var soul_sorted = [soul[0], soul[1], soul[2], soul[3]]
    soul_sorted.sort()
    return basic_projectiles["{0}_{1}_{2}_{3}".format([soul_sorted[0], soul_sorted[1], soul_sorted[2], soul_sorted[3]])]

func attack():
    if attack_cooldown_counter > 0:
        pass
    else:
        attack_cooldown_counter = 4
        
        var thrown_irla = get_node("BasicProjectile")
        thrown_irla.held = false
        thrown_irla.base_speed = 2
        thrown_irla.position_fixed = false
        thrown_irla.direction = direction
        thrown_irla.get_node("CollisionShape2D").disabled = false
        var radius = thrown_irla.get_node("CollisionShape2D").shape.radius
        thrown_irla.position = position + direction * 2 * (radius + get_node("CollisionShape2D").shape.radius)
        thrown_irla.speed = [speed[0], speed[1], speed[2], speed[3]]
        thrown_irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        thrown_irla.soul = soul.duplicate()
        remove_child(thrown_irla)
        get_parent().add_child(thrown_irla)

        var new_irla = BasicProjectile.instance()
        new_irla.held = true
        new_irla.speed = [0, 0, 0, 0]
        new_irla.base_speed = 0
        new_irla.position_fixed = true
        new_irla.get_node("CollisionShape2D").disabled = true
        new_irla.position = position + direction * 2 * (radius + get_node("CollisionShape2D").shape.radius)
        new_irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        new_irla.direction = Vector2(direction[0], direction[1])
        add_child(new_irla)

func burn(damage):
    var animated_sprite = get_node("AnimatedSprite")
    animated_sprite.play("burn")
    health -= damage

func use_fire_shield():
    if fire_shield_cooldown_counter > 0:
        burn(1)
    else:
        fire_shield_cooldown_counter = 50
        fire_shield_counter = 30
        invincible = true
        fire_shield = FireShield.instance()
        add_child(fire_shield)

func disable_fire_shield():
    invincible = false
    if fire_shield != null:
        #print("removing fire shield")
        remove_child(fire_shield)
    fire_shield = null
    fire_shield_counter = 0

func use_soul_special():
    var soul_string = "{0}_{1}_{2}_{3}".format([soul[0], soul[1], soul[2], soul[3]])
    if soul_string == "0_0_0_0":
        use_fire_shield()
    else:
        attack()

func _process(delta):
    if (first_run):
        first_run = false
        var children = get_children()
        var irla = get_children()[2]
        irla.held = true
        irla.speed = [0, 0, 0, 0]
        irla.base_speed = 0
        irla.position_fixed = true
        irla.get_node("CollisionShape2D").disabled = true
        irla.position = direction * 2 * get_node("CollisionShape2D").shape.radius
        irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        
    if Input.is_action_just_pressed("ui_cancel"):
        use_soul_special()
    
    if Input.is_action_just_pressed("ui_home"):
        soul_push_back(0)
    
    if Input.is_action_just_pressed("ui_page_up"):
        soul_push_back(1)
    
    if Input.is_action_just_pressed("ui_page_down"):
        soul_push_back(2)
        
    if Input.is_action_just_pressed("ui_end"):
        soul_push_back(3)
      
    # long chain of exclusive combinations of arrow key inputs, used to control direction of animation, speed of movement, and direction of movement
    if !(Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left")):
        # standing animation
        var sprite = get_node("AnimatedSprite")
        # sprite needs to not be rotated, so it is always face up
        sprite.rotation = 0
        rotation = 0
        #print("stand")
        stand(delta)
        
    elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
        pass
    
    elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
        move(1, delta)
    
    elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
        move(2, delta)
       
    elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
        move(3, delta)
    
    elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right"):
        move(0, delta)
    
    elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
        move(4, delta)
        
    elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
        move(5, delta)
        
    elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
        move(6, delta)
        
    elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_down"):
        move(7, delta)
    
    elif Input.is_action_pressed("ui_up"):
        move(0, delta)
        
    elif Input.is_action_pressed("ui_right"):
        move(1, delta)
        
    elif Input.is_action_pressed("ui_down"):
        move(2, delta)
        
    elif Input.is_action_pressed("ui_left"):
        move(3, delta)
    
    for i in len(speed):
        if speed[i] <= 0:
            speed[i] = 0
        elif speed[i] > stopping_speed:
            speed[i] -= drag * speed[i] * delta   
        else:
            speed[i] -= drag * stopping_speed * delta
    
        if speed[i] < 0:
            speed[i] = 0
    
    var v = Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]
    position += min(speed_limit, v.length()) * delta * direction

    if Input.is_action_just_pressed("ui_accept"):
        attack()
    
    if position.x <= left_boundary_position + get_node("CollisionShape2D").shape.radius:
        # reverse
        position.x = left_boundary_position + get_node("CollisionShape2D").shape.radius
        #if rotation < 180:
        #    rotation += 180
        #else:
        #    rotation -= 180
        var t = speed[1]
        speed[1] = speed[3]
        speed[3] = t
        direction.x = -direction.x
    
    elif position.x >= right_boundary_position - get_node("CollisionShape2D").shape.radius:
        # reverse
        position.x = right_boundary_position - get_node("CollisionShape2D").shape.radius
        #if rotation < 180:
        #    rotation += 180
        #else:
        #    rotation -= 180
        var t = speed[1]
        speed[1] = speed[3]
        speed[3] = t
        direction.x = -direction.x
        
    if position.y <= top_boundary_position + get_node("CollisionShape2D").shape.radius:
        # reverse
        position.y = top_boundary_position + get_node("CollisionShape2D").shape.radius
        #if rotation < 180:
        #    rotation += 180
        #else:
        #    rotation -= 180
        var t = speed[0]
        speed[0] = speed[2]
        speed[2] = t
        direction.x = -direction.x
        
    elif position.y >= bottom_boundary_position - get_node("CollisionShape2D").shape.radius:
        # reverse
        position.y = bottom_boundary_position - get_node("CollisionShape2D").shape.radius
        #if rotation < 180:
        #    rotation += 180
        #else:
        #    rotation -= 180
        var t = speed[0]
        speed[0] = speed[2]
        speed[2] = t
        direction.x = -direction.x
    
    # determine the closest cardinal direction, and animate based on that
    var angle = direction.angle_to(Vector2.RIGHT) * 180/PI # bounded [-180, 180)
    var sprite = get_node("AnimatedSprite")
    #print(angle)
    #print(animation_prefix)
    if angle >= -22.5 && angle < 22.5:
        #print("walk_right")
        sprite.play(animation_prefix + "_right")
        
    elif angle >= 22.5 and angle < 67.5:
        #print("walk_back_right")
        sprite.play(animation_prefix + "_back_right")
        
    elif angle >= 67.5 and angle < 112.5:
        #print("walk_back")
        sprite.play(animation_prefix + "_back")
        
    elif angle >= 112.5 and angle < 157.5:
        #print("walk_back_left")
        sprite.play(animation_prefix + "_back_left")
        
    elif angle >= 157.5 || angle < -157.5:
        #print("walk_left")
        sprite.play(animation_prefix + "_left")
        
    elif angle >= -157.5 and angle < -112.5:
        #print("walk_front_left")
        sprite.play(animation_prefix + "_front_left")
        
    elif angle >= -112.5 and angle < -67.5:
        #print("walk_front")
        sprite.play(animation_prefix + "_front")
        
    elif angle >= -157.5 and angle < -22.5:
        #print("walk_front_right")
        sprite.play(animation_prefix + "_front_right")
    
    # hang onto the previous delta in case we need to use it to calculate stuff
    last_delta = delta
        
func take_damage(hit_base_damage, hit_soul):
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
        
    health -= damage
    
    emit_signal("player_hit", health, damage, max_health)
    
    #print("player hit by projecile soul: {0} {1} {2} {3}".format([hit_soul[0], hit_soul[1], hit_soul[2], hit_soul[3]]))
    #print("took damage: %s" % damage)
    #print("health remaining: %s" % health)
    
    if health <= 0:
        die()

func die():
    if health > 0:
        health = 0
        emit_signal("player_hit", 0, 1, max_health)
    print("game over")
    queue_free()

func _on_Player_area_entered(area):
    if "type" in area:
        if area.type == "b":
            take_damage(area.base_damage, area.soul)
            area.queue_free()
    pass # Replace with function body.


func _on_Timer_timeout():
    if fire_shield_counter > 0:
        fire_shield_counter -= 1
    else:
        disable_fire_shield()
        
    if fire_shield_cooldown_counter > 0:
        fire_shield_cooldown_counter -= 1
    
    if attack_cooldown_counter > 0:
        attack_cooldown_counter -= 1

func _on_AnimatedSprite_animation_finished():
    #print("non-looping animation finished")
    var animated_sprite = get_node("AnimatedSprite")
    if animated_sprite.animation != "default":
        animated_sprite.animation = "default"
        animated_sprite.play()


func _on_Player_player_attack(soul):
    pass # Replace with function body.
