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

var type = "p"

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const len_soul = 4
const base_drag = 4
const BasicProjectile = preload("res://BasicProjectile.tscn")
const basic_projectiles = {"0_0_0_0": preload("res://basic_projectile_0_0_0_0.png"), "0_0_0_1": preload("res://basic_projectile_0_0_0_1.png"), "0_0_0_2": preload("res://basic_projectile_0_0_0_2.png"), "0_0_0_3": preload("res://basic_projectile_0_0_0_3.png"), "0_0_1_1": preload("res://basic_projectile_0_0_1_1.png"), "0_0_1_2": preload("res://basic_projectile_0_0_1_2.png"), "0_0_1_3": preload("res://basic_projectile_0_0_1_3.png"), "0_0_2_2": preload("res://basic_projectile_0_0_2_2.png"), "0_0_2_3": preload("res://basic_projectile_0_0_2_3.png"), "0_0_3_3": preload("res://basic_projectile_0_0_3_3.png"), "0_1_1_1": preload("res://basic_projectile_0_1_1_1.png"), "0_1_1_2": preload("res://basic_projectile_0_1_1_2.png"), "0_1_1_3": preload("res://basic_projectile_0_1_1_3.png"), "0_1_2_2": preload("res://basic_projectile_0_1_2_2.png"), "0_1_2_3": preload("res://basic_projectile_0_1_2_3.png"), "0_1_3_3": preload("res://basic_projectile_0_1_3_3.png"), "0_2_2_2": preload("res://basic_projectile_0_2_2_2.png"), "0_2_2_3": preload("res://basic_projectile_0_2_2_3.png"), "0_2_3_3": preload("res://basic_projectile_0_2_3_3.png"), "0_3_3_3": preload("res://basic_projectile_0_3_3_3.png"), "1_1_1_1": preload("res://basic_projectile_1_1_1_1.png"), "1_1_1_2": preload("res://basic_projectile_1_1_1_2.png"), "1_1_1_3": preload("res://basic_projectile_1_1_1_3.png"), "1_1_2_2": preload("res://basic_projectile_1_1_2_2.png"), "1_1_2_3": preload("res://basic_projectile_1_1_2_3.png"), "1_1_3_3": preload("res://basic_projectile_1_1_3_3.png"), "1_2_2_2": preload("res://basic_projectile_1_2_2_2.png"), "1_2_2_3": preload("res://basic_projectile_1_2_2_3.png"), "1_2_3_3": preload("res://basic_projectile_1_2_3_3.png"), "1_3_3_3": preload("res://basic_projectile_1_3_3_3.png"), "2_2_2_2": preload("res://basic_projectile_2_2_2_2.png"), "2_2_2_3": preload("res://basic_projectile_2_2_2_3.png"), "2_2_3_3": preload("res://basic_projectile_2_2_3_3.png"), "2_3_3_3": preload("res://basic_projectile_2_3_3_3.png"), "3_3_3_3": preload("res://basic_projectile_3_3_3_3.png")}
    
signal soul_switch(soul)
signal player_attack(soul)

func _init():
    window_size = OS.get_real_window_size()
    position = Vector2(window_size[0] / 2, window_size[1] / 2)
    
    soul = [0, 0, 0, 0]    
    speed = [0, 0, 0, 0]
    
    direction = Vector2.ZERO
    
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

func get_basic_projectile(soul):
    var soul_sorted = [soul[0], soul[1], soul[2], soul[3]]
    soul_sorted.sort()
    return basic_projectiles["{0}_{1}_{2}_{3}".format([soul_sorted[0], soul_sorted[1], soul_sorted[2], soul_sorted[3]])]

func attack():
    var projectile = BasicProjectile.instance()
    projectile.direction = Vector2(direction[0], direction[1])
    projectile.position = Vector2(position[0], position[1])
    projectile.speed = [speed[0], speed[1], speed[2], speed[3]]
    projectile.get_node("Sprite").texture = get_basic_projectile(soul)
    get_parent().add_child(projectile)

func _process(delta):
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
