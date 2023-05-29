extends Area2D

var damage_key
var health
var speed
var direction
var start_move_to_player_count
var stop_move_to_player_count
var base_projectile_speed
var attack_player_count

const projectile_texture = preload("res://basic_projectile.png")
const BasicProjectile = preload("res://BasicProjectile.tscn")

func _init():
    #var size = OS.get_real_window_size()
    #position = Vector2(size[0] / 2, size[1] / 2)
    
    damage_key = [-1, 1, -1, -1]
    health = 10
    speed = 0
    direction = Vector2.ZERO
    start_move_to_player_count = 0
    stop_move_to_player_count = 0
    attack_player_count = 2
    base_projectile_speed = 4
    
func take_damage(soul):
    var damage = 0
    for i in 4:
        damage += damage_key[soul[i]]
    health -= damage
    print("hit by soul: {} {} {} {}".format([soul[0], soul[1], soul[2], soul[3]]))
    print("took damage: %s" % damage)
    print("health remaining: %s" % health)
    if health <= 0:
        queue_free()

func _on_Trap_area_entered(area):
    if "speed" in area:
        area.speed = [0, 0, 0, 0]
    if "direction" in area:
        area.direction = Vector2.ZERO
    if "drag" in area:
        area.drag = 40
    if "type" in area:
        if area.type == "b":
            take_damage(area.soul)
            area.queue_free()

func _on_Trap_area_exited(area):
    if "drag" in area:
        area.drag = 10

func attack_player(player):
    if ! player:
        return
    attack_player_count = 3
    var pos = player.position
    var target_pos = Vector2(pos[0], pos[1])
    var proj = BasicProjectile.instance()
    proj.direction = position.direction_to(target_pos)
    var shape = get_node("CollisionShape2D").shape
    var radius = shape.radius
    proj.position = position + 1.5 * radius * proj.direction
    proj.speed = [0, 0, 0, 0]
    proj.base_speed = base_projectile_speed
    proj.soul = [2, 2, 2, 2]
    proj.get_node("Sprite").texture = projectile_texture
    get_parent().add_child(proj)
    
func start_move_to_player(player):
    if ! player:
        return
    # cooldown of move action
    start_move_to_player_count = 3
    # duration of movement
    stop_move_to_player_count = 1
    speed = 100
    direction = position.direction_to(player.position)

func stop_move_to_player():
    speed = 0
    direction = Vector2.ZERO

var ticktock = "tock"
var ticktock_count = 3

func _on_Timer_timeout():
    if ticktock_count < 3:
        ticktock_count += 1
    else:
        if (ticktock == "tock"):
            ticktock = "tick"
        else:
            ticktock = "tock"
        print(ticktock)
        print("\n")
        ticktock_count = 0
    
    var player = get_parent().get_node("Player")
    
    if stop_move_to_player_count == 0:
        stop_move_to_player()
    else:
        stop_move_to_player_count -= 1

    if start_move_to_player_count == 0:
        start_move_to_player(player)
    else:
       start_move_to_player_count -= 1
    
    if attack_player_count == 0:
        attack_player(player)
    else:
        attack_player_count -= 1
    
        
func _process(delta):
    if speed > 0.000001 and direction.length() > 0.000001:
        position += speed * direction * delta
