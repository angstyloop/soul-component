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

const projectile_texture = preload("res://ice_spikes.png")
const BasicProjectile = preload("res://BasicProjectile.tscn")

func _init():
    #var size = OS.get_real_window_size()
    #position = Vector2(size[0] / 2, size[1] / 2)
    
    damage_key = [1, -1, -1, -1]
    health = 10
    speed = 0
    spin_speed = 0
    direction = Vector2.ZERO
    base_projectile_speed = 50
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
    spin_speed = 3

func stop_spinning():
    spin_speed = 0
    rotation = 0

func do_actions(player):
    #print(beat_counter)
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
    if damage > 0:
        get_node("AnimatedSprite").play("hit")
    elif damage < 0:
        get_node("AnimatedSprite").play("heal")
    else:
        # laugh
        pass
    health -= damage
    #print("hit by soul: {} {} {} {}".format([soul[0], soul[1], soul[2], soul[3]]))
    #print("took damage: %s" % damage)
    #print("health remaining: %s" % health)
    if health <= 0:
        queue_free()

var air_shield_threshold_speed = 300

func dodge():
    get_node("AnimatedSprite").play("dodge")

func _on_Yuki_area_entered(area):
    if "type" in area:
        if area.type == "b":
            var proj_speed = (area.base_speed * area.direction + Vector2.UP * area.speed[0] + Vector2.RIGHT * area.speed[1] + Vector2.DOWN * area.speed[2] + Vector2.LEFT * area.speed[3]).length()
            if proj_speed  > air_shield_threshold_speed:
                # hit by fast projectile
                take_damage(area.soul)
                area.queue_free()
            else:
                # freeze slow projectile
                #area.speed = [0, 0, 0, 0]
                #area.angular_speed = 0
                #area.direction = Vector2.ZERO
                
                # dodge slow projectile
                dodge()
                
        elif area.type == "p":
            # ensnare slow player
            if ! area.invincible:
                area.queue_die()

func _on_Yuki_area_exited(area):
    if "drag" in area:
        area.drag = 10

func attack_player(player):
    if ! player:
        if spin_speed == 0:
            start_spinning()
        return
    get_node("AnimatedSprite").play("attack")
    var pos = player.position
    var target_pos = Vector2(pos[0], pos[1])
    var proj = BasicProjectile.instance()
    proj.direction = position.direction_to(target_pos)
    var ice_spikes_radius = 24
    proj.position = position + 2.5 * ice_spikes_radius * proj.direction
    proj.speed = [0, 0, 0, 0]
    proj.base_speed = base_projectile_speed
    proj.soul = [2, 2, 2, 2]
    proj.base_damage = INF
    proj.get_node("CollisionShape2D").shape.radius = ice_spikes_radius
    proj.get_node("Sprite").texture = projectile_texture
    get_parent().add_child(proj)
    
func start_move_to_player(player):
    if ! player:
        if spin_speed == 0:
            start_spinning()
        return
    speed = 300
    direction = position.direction_to(player.position)

func stop_move_to_player(_player):
    speed = 0
    direction = Vector2.ZERO

func _on_Timer_timeout():
    var player = get_parent().get_node("Player")
    
    do_actions(player)
        
func _on_AnimatedSprite_animation_finished():
    var animated_sprite = get_node("AnimatedSprite")
    if animated_sprite.animation != "default":
        animated_sprite.animation = "default"
        animated_sprite.play("default")

func _process(delta):
    if speed > 0.000001 and direction.length() > 0.000001:
        position += speed * direction * delta
    
    if spin_speed > 0.000001:
        rotation += fmod((spin_speed * delta), 360)
