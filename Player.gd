extends Area2D

var speed
var spin_speed = 12
var direction
var speed_sum
var soul
const len_soul = 4
const initial_speed = 1
const speed_limit = 10000
const initial_acceleration = 5000
const acceleration_growth = 100
const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var drag
const stopping_speed = 250

signal soul_switch(soul)

func _init():
    var size = OS.get_real_window_size()
    position = Vector2(size[0] / 2, size[1] / 2)
    
    speed = [0, 0, 0, 0]
    direction = Vector2.ZERO
    soul = [0, 0, 0, 0]
    drag = 10

func soul_push_back(soul_index):
    for i in len_soul - 1:
        soul[i] = soul[i + 1]
    soul[len_soul - 1] = soul_index
    emit_signal("soul_switch", soul)
        
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
    
func _process(delta):
    if Input.is_action_just_pressed("ui_home"):
        soul_push_back(0)
        print(soul)
    
    if Input.is_action_just_pressed("ui_page_up"):
        soul_push_back(1)
        print(soul)
    
    if Input.is_action_just_pressed("ui_page_down"):
        soul_push_back(2)
        print(soul)
        
    if Input.is_action_just_pressed("ui_end"):
        soul_push_back(3)
        print(soul)
    
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
    
    speed_sum = speed[0] + speed[1] + speed[2] + speed[3]
    
    for i in len(speed):
        if speed[i] <= 0:
            speed[i] = 0
        elif speed[i] > stopping_speed:
            speed[i] -= drag * speed[i] * delta   
        else:
            speed[i] -= drag * stopping_speed * delta
            
    position += (Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]) * delta
    rotation = -direction.angle_to(directions[2])
