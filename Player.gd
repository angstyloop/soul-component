extends Area2D

var speed
var speed_sum
var direction
var soul
const len_soul = 4
const initial_speed = 1
const speed_limit = 10000
const initial_acceleration = 5000
const acceleration_growth = 100
const drag = 10
const stopping_speed = 250
#var angular_speed = PI

func _init():
    var size = OS.get_real_window_size()
    position = Vector2(size[0] / 2, size[1] / 2)
    
    speed = [0, 0, 0, 0]
    direction = Vector2.ZERO
    soul = [0, 0, 0, 0]

func soul_push_back(el):
    for i in len_soul - 1:
        soul[i] = soul[i + 1]
    soul[len_soul - 1] = el
        
func move(direction_index, delta):
        if speed[direction_index] == 0:
            speed[direction_index] = initial_speed
        
        speed[direction_index]  += initial_acceleration * exp(acceleration_growth * delta) * delta
        
        if speed[direction_index]  > speed_limit:
            speed[direction_index]  = speed_limit
    
func _process(delta):
    #var direction = 0    
    
    if Input.is_action_just_pressed("ui_up"):
        direction = Vector2.UP
    
    if Input.is_action_just_pressed("ui_right"):
        direction = Vector2.RIGHT
        
    if Input.is_action_just_pressed("ui_down"):
        direction = Vector2.DOWN
            
    if Input.is_action_just_pressed("ui_left"):
        direction = Vector2.LEFT
    
    if Input.is_action_pressed("ui_up"):
        move(0, delta)
    
    if Input.is_action_pressed("ui_right"):
        move(1, delta)
    
    if Input.is_action_pressed("ui_down"):
        move(2, delta)

    #rotation += angular_speed * direction * delta
    
    if Input.is_action_pressed("ui_left"):
        #velocity = Vector2.UP.rotated(rotation) * speed
        move(3, delta)
    
    if Input.is_action_pressed("ui_home"):
        soul_push_back(0)
        print(soul)
        pass
    
    if Input.is_action_pressed("ui_page_up"):
        soul_push_back(1)
        print(soul)
        pass
    
    if Input.is_action_pressed("ui_page_down"):
        soul_push_back(2)
        print(soul)
        pass
        
    if Input.is_action_pressed("ui_end"):
        soul_push_back(3)
        print(soul)
        pass
    
    speed_sum = speed[0] + speed[1] + speed[2] + speed[3]
    
    for i in len(speed):
        if speed[i] <= 0:
            speed[i] = 0
        elif speed[i] > stopping_speed:
            speed[i] -= drag * speed[i] * delta   
        else:
            speed[i] -= drag * stopping_speed * delta
        
    position += (Vector2.UP * speed[0] + Vector2.RIGHT * speed[1] + Vector2.DOWN * speed[2] + Vector2.LEFT * speed[3]) * delta

func _on_Player_area_entered(_area):
    print("hi")
    
func _on_Player_area_exited(_area):
    print("bye")
