extends Area2D

var direction
var bite = false
var bite_counter = 0
var bite_counter_max = 16
var old_player_position
var old_player_speed
var old_player_direction

var ignore_invincible = true

var speed = 0
var speed_max = 500 

var ji
var sprite

var move = false
var move_counter = 0
var move_counter_max = 4

func _init():
    visible = false

func _process(delta):
    if bite:
        return
        
    start_move(delta)

func start_bite(area):
    bite = true
    bite_counter = bite_counter_max
    
    if !sprite:
        sprite = $AnimatedSprite
    
    visible = true
    sprite.stop()
    sprite.animation = "bite"
    sprite.frame = 0
    sprite.play()
    area.speed = 0
    position = area.position

func end_bite():
    bite = false
    sprite.stop()
    sprite.animation = "move"
    sprite.frame = 0
    # don't play
    #sprite.play()
    #hide
    visible = false
    
func start_move(delta):
    if speed && direction:
        position += speed * direction * delta
        #rotation = PI / 2 - direction.angle_to(Vector2.DOWN)
    if old_player_direction && old_player_direction < 400:
        visible = false
        
func end_move():
    speed = 0

func _on_Timer_timeout():
    if bite:
        if bite_counter > 0:
            bite_counter -= 1
        else:
            end_bite()
    
    if move:
        if move_counter > 0:
            move_counter -= 1
        else:
            end_move()

func _on_IceWorm_area_entered(area):
    if "type" in area:
        if area.type == "p":
            area.rotation = PI/3
            area.direction = area.position.direction_to(position)
            area.speed = 0
            start_bite(area)        
            area.queue_die()

var safe_zone_radius = 5000

func _on_Ji_player_move(old_position, old_speed, old_direction, displacement):
    print("player move")
    
    old_player_position = old_position

    if old_position.length() > safe_zone_radius:
        visible = true
        direction = position.direction_to(old_position) 
        var d = (old_position - position).length()   
        speed = speed_max        
    else:
        direction = -position.direction_to(old_position)
        if position.length() > 2 * safe_zone_radius:
            speed = 0
            visible = false
