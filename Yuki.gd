extends Area2D

var progress = [0, 0, 0, 0, 0]

var damage_key
var health
var speed
var direction
var base_projectile_speed
var beat_counter
var beat_array
var spin_speed
var omni_gate_used
var soul
var radius
var projectile_radius
var ignore_invincible = true

var ice = false
var ice_count = 0
var ice_count_max = 2
var ice_animation_started = false

# not used yet
var animation_prefix = ""

signal die()

enum {START_MOVE_TO_PLAYER,  STOP_MOVE_TO_PLAYER, ATTACK_PLAYER, START_SPINNING, STOP_SPINNING}

const projectile_texture = preload("res://ice_spikes.png")
const YukiProjectile = preload("res://YukiProjectile.tscn")

func _init():
    load_game()
    
    #var size = OS.get_real_window_size()
    #position = Vector2(size[0] / 2, size[1] / 2)
    omni_gate_used = false
    damage_key = [1, -1, -1, -1]
    soul = [1, 3, 3, 3]
    # 5 is very easy, 10 is easy, 15 is medium, 20 is difficult
    health = 15 # health 5 for testing. 15 normally.
    speed = 0
    spin_speed = 0
    projectile_radius = 24
    direction = Vector2.ZERO
    beat_counter = 0
    beat_array = [
        [ATTACK_PLAYER], [], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [], [], [],
        [ATTACK_PLAYER], [], [], [],
        [], [], [], [],
        [], [], [], [STOP_MOVE_TO_PLAYER],
        
        [ATTACK_PLAYER, START_MOVE_TO_PLAYER], [], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [STOP_MOVE_TO_PLAYER],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [], [], [],
        [], [], [], [],
        [], [], [], [],
        [STOP_MOVE_TO_PLAYER], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER], [], [ATTACK_PLAYER],
        [], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        #
        
        [ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [ATTACK_PLAYER], [], [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER],
        [ATTACK_PLAYER], [], [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER],
        [], [], [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER],
        [], [], [START_MOVE_TO_PLAYER], [STOP_MOVE_TO_PLAYER],

        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [STOP_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [STOP_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [] , [ATTACK_PLAYER], [],
        [STOP_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [ATTACK_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [START_MOVE_TO_PLAYER], [],
        [STOP_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [START_MOVE_TO_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
        
        [START_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [START_MOVE_TO_PLAYER], [],
        [STOP_MOVE_TO_PLAYER, ATTACK_PLAYER], [], [START_MOVE_TO_PLAYER], [],
        [], [], [], [],
        [], [], [], [],
  
        [], [], [], [],
        [], [], [], [],
        [], [], [], [],
        [], [], [], [],
        
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
    print(len(beat_array))
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

static func get_soul_component(soul, i):
    var sum = 0
    for j in soul:
        if j == i:
            sum += 1
    return sum

static func get_base_damage(soul):
    return 1 + floor(.5 * get_soul_component(soul, 0)) - floor(.5 * get_soul_component(soul, 1))

static func get_damage(own_soul, hit_soul):
    var damage = get_base_damage(hit_soul)
    for i in hit_soul:
        if i == 3:
            pass
        else:
            var weakness
            if i == 0:
                weakness = 2
            else:
                weakness = i - 1
                
            for j in own_soul:
                if j == weakness:
                    damage += 1
    return damage

func save_game():
    var f = File.new()
    f.open("user://savegame.save", File.WRITE)
    var data = { "progress": progress } 
    f.store_line(to_json(data))
    f.close()
    
func load_game():
    var f = File.new()
    if not f.file_exists("user://savegame.save"):
        return
    f.open("user://savegame.save", File.READ)
    var data = parse_json(f.get_line())
    progress = data.progress
    f.close()

func take_damage(hit_soul):
    var damage = get_base_damage(hit_soul)
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
    print("health remaining: %s" % health)
    if health <= 0:
        die()

var air_shield_threshold_speed = 100

func die():
    progress[1] = 1
    save_game()
    emit_signal("die")
    queue_free()
    
func dodge():
    get_node("AnimatedSprite").play("dodge")

static func get_speed_limit(soul):
    return 200 * (1 + get_soul_component(soul, 3))

func _on_Yuki_area_entered(area):
    if "type" in area:
        if area.type == "b":
            var proj_speed = speed
            if proj_speed  > air_shield_threshold_speed:
                # hit by fast projectile
                take_damage(area.soul)
                area.hit = true
            else:
                # freeze slow projectile
                #area.speed = 0
                #area.angular_speed = 0
                #area.direction = Vector2.ZERO
                
                # dodge slow projectile
                dodge()
                
        elif area.type == "p":
            ice = true
            ice_count = ice_count_max
            speed = 0
            area.position = position
            area.queue_die()
        
        elif area.type == "y":
            # own projectile
            pass

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
    var proj = YukiProjectile.instance()
    proj.direction = position.direction_to(target_pos)
    if !radius:
        radius = $CollisionShape2D.shape.radius
    proj.position = position
    proj.speed = speed
    proj.get_node("CollisionShape2D").shape.radius = projectile_radius
    proj.get_node("Sprite").texture = projectile_texture
    get_parent().add_child(proj)
    
func start_move_to_player(player):
    if ! player:
        if spin_speed == 0:
            start_spinning()
        return
    speed = get_speed_limit(soul)
    direction = position.direction_to(player.position)

func stop_move_to_player(_player):
    speed = 0
    direction = Vector2.ZERO

func _on_Beats_timeout():
    if not omni_gate_used and ji_ready:
        do_actions(get_parent().get_node("Ji"))
    
    if ice:
        if ice_count > 0:
            ice_count -= 1
        else:
            print("yo")
            if !ice_animation_started:
                var sprite = $AnimatedSprite
                sprite.stop()
                sprite.animation = "ice"
                sprite.frame = 0
                sprite.play()
                ice_animation_started = true
        
func _on_AnimatedSprite_animation_finished():
    var animated_sprite = get_node("AnimatedSprite")
    if animated_sprite.animation != "default" && animated_sprite.animation != "ice":
        animated_sprite.animation = "default"
        animated_sprite.play("default")

var ji_ready = false

func _process(delta):
    if !ji_ready:
        return
    
    if ice_animation_started:
        return
    
    if speed > 0.000001 and direction.length() > 0.000001:
        position += speed * direction * delta
    
    if spin_speed > 0.000001:
        rotation += fmod((spin_speed * delta), 360)


func _on_Ji_use_omni_gate():
    omni_gate_used = true
    speed = 0
    spin_speed = 0
    get_node("AnimatedSprite").stop()
    get_node("CollisionShape2D").disabled = true



func _on_Ji_ji_ready():
    ji_ready = true
