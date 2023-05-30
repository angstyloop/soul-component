extends Area2D

var damage_key
var health
var speed
var direction
var base_projectile_speed
var beat_counter
var beat_array
var spin_speed

enum {START_MOVE_TO_PLAYER,  STOP_MOVE_TO_PLAYER, ATTACK_PLAYER, START_SPINNING, STOP_SPINNING}

const projectile_texture = preload("res://basic_projectile.png")
const BasicProjectile = preload("res://BasicProjectile.tscn")

func _init():
    #var size = OS.get_real_window_size()
    #position = Vector2(size[0] / 2, size[1] / 2)
    
    damage_key = [-1, 1, -1, -1]
    health = 10
    speed = 0
    spin_speed = 0
    direction = Vector2.ZERO
    base_projectile_speed = 10
    beat_counter = 0
    beat_array = [
        [START_MOVE_TO_PLAYER], [], [], [],
        [STOP_MOVE_TO_PLAYER], [], [], [],
        [START_MOVE_TO_PLAYER], [], [], [],
        [STOP_MOVE_TO_PLAYER], [], [], [],
        
        [START_MOVE_TO_PLAYER], [], [], [],
        [STOP_MOVE_TO_PLAYER], [], [], [],
        [START_MOVE_TO_PLAYER], [], [], [],
        [STOP_MOVE_TO_PLAYER], [], [], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        [START_MOVE_TO_PLAYER], [], [STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER], [], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [],
        
        #
        
        [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER],
        [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER],
        [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER],
        [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [ATTACK_PLAYER], [ATTACK_PLAYER, STOP_MOVE_TO_PLAYER], [ATTACK_PLAYER],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
  
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [START_MOVE_TO_PLAYER, ATTACK_PLAYER],
        
        [START_SPINNING], [], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [STOP_SPINNING],
    ]

func start_spinning():
    spin_speed = 8

func stop_spinning():
    spin_speed = 0
    rotation = 0

func do_actions(player):
    print(beat_counter)
    for action in beat_array[beat_counter]:
        if (action == START_MOVE_TO_PLAYER):
            start_move_to_player(player)
        elif (action == STOP_MOVE_TO_PLAYER):
            stop_move_to_player(player)
        elif (action == ATTACK_PLAYER):
            attack_player(player)
        elif (action == START_SPINNING):
            start_spinning()
        elif (action == STOP_SPINNING):
            stop_spinning()
    if (beat_counter == 367):
        beat_counter = 0
        var audio = get_parent().get_node("AudioStreamPlayer2D")
        audio.stop()
        audio.play(0)
    else:
        beat_counter += 1
  
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
    speed = 200
    direction = position.direction_to(player.position)

func stop_move_to_player(_player):
    speed = 0
    direction = Vector2.ZERO

func _on_Timer_timeout():
    var player = get_parent().get_node("Player")
    
    do_actions(player)
        
func _process(delta):
    if speed > 0.000001 and direction.length() > 0.000001:
        position += speed * direction * delta
    
    if spin_speed > 0.000001:
        rotation += fmod((spin_speed * delta), 360)
