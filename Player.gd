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

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const len_soul = 4
const base_drag = 4
const BasicProjectile = preload("res://BasicProjectile.tscn")

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
    if (Vector2.ZERO - direction).length() < 0.000001:
        direction = directions[direction_index]
    else:
        direction = (direction + directions[direction_index]) / sqrt(2)
    if speed[direction_index] == 0:
        speed[direction_index] = initial_speed
    
    speed[direction_index]  += initial_acceleration * exp(acceleration_growth * delta) * delta
    
    if speed[direction_index]  > speed_limit:
        speed[direction_index]  = speed_limit

func attack():
    var projectile = BasicProjectile.instance()
    projectile.direction = direction
    projectile.position = position
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
            
    position += (Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]) * delta
    rotation = -direction.angle_to(directions[2])

    if Input.is_action_just_pressed("ui_accept"):
        attack()
