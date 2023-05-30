extends Area2D

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

var health
var armor
var invincible

var fire_shield = null
var fire_shield_counter
var fire_shield_cooldown_counter
var attack_cooldown_counter

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

func _init():
    window_size = OS.get_real_window_size()
    #position = Vector2(window_size[0] / 2, window_size[1] / 2)
    
    soul = [0, 0, 0, 0]    
    speed = [0, 0, 0, 0]
    
    direction = Vector2.ZERO
    
    health = 10
    
    invincible = false
    
    fire_shield_counter = 0
    fire_shield_cooldown_counter = 0
    attack_cooldown_counter = 0
    
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
    return 1 * get_soul_component(soul, 3)

static func get_speed_limit(soul):
    return 2500 * get_soul_component(soul, 3)

static func get_initial_acceleration(soul):
    return 1250 * get_soul_component(soul, 3)

static func get_acceleration_growth(soul):
    return 25 * get_soul_component(soul, 3)

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
        
func move(direction_index, delta):
    if speed[direction_index] == 0:
        speed[direction_index] = initial_speed
    
    speed[direction_index]  += initial_acceleration * exp(acceleration_growth * delta) * delta
    
    if speed[direction_index]  > speed_limit:
        speed[direction_index]  = speed_limit
    
    var v = Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]
    
    if v.length() > 0.0001:
        direction = v / v.length()

    rotation = -direction.angle_to(directions[2])

func get_basic_projectile_texture(soul):
    var soul_sorted = [soul[0], soul[1], soul[2], soul[3]]
    soul_sorted.sort()
    return basic_projectiles["{0}_{1}_{2}_{3}".format([soul_sorted[0], soul_sorted[1], soul_sorted[2], soul_sorted[3]])]

func attack():
    if attack_cooldown_counter > 0:
        pass
    else:
        attack_cooldown_counter = 4
        var projectile = BasicProjectile.instance()
        projectile.direction = Vector2(direction[0], direction[1])
        var radius = projectile.get_node("CollisionShape2D").shape.radius
        projectile.position = Vector2(position[0], position[1]) + 10 * radius * projectile.direction
        projectile.speed = [speed[0], speed[1], speed[2], speed[3]]
        projectile.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        projectile.soul = soul.duplicate()
        get_parent().add_child(projectile)

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
        print("removing fire shield")
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
    
    if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
        rotation += fmod((spin_speed * delta), 360)
        return
    
    elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
        move(1, delta)
    
    elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
        move(2, delta)
        
    elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
        move(3, delta)
    
    elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right"):
        move(0, delta)
    
    else:        
        if Input.is_action_pressed("ui_up"):
            move(0, delta)
        
        if Input.is_action_pressed("ui_right"):
            move(1, delta)
        
        if Input.is_action_pressed("ui_down"):
            move(2, delta)

        if Input.is_action_pressed("ui_left"):
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
    position += v * delta

    if Input.is_action_just_pressed("ui_accept"):
        attack()
        
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
    
    print("player hit by projecile soul: {0} {1} {2} {3}".format([hit_soul[0], hit_soul[1], hit_soul[2], hit_soul[3]]))
    print("took damage: %s" % damage)
    print("health remaining: %s" % health)
    
    if health <= 0:
        queue_free()
        game_over()

func game_over():
    print("game over")

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
    var animated_sprite = get_node("AnimatedSprite")
    if animated_sprite.animation != "default":
        print("um")
        animated_sprite.animation = "default"
        animated_sprite.play()
