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

var ignore_invincible = false

var footsteps_on = true
var breath_on = true

var thrown_irla = null
var held_irla = null

var last_delta

var health
var max_health
var armor
var invincible

var first_run = true
var first_run_count_max = 4
var first_run_count = first_run_count_max
var first_run_animation_started = false

var fire_shield = null
var fire_shield_counter
var fire_shield_cooldown_counter
var attack_cooldown_counter
const attack_cooldown_counter_max = 4
var ready_to_die
var die_counter
var animation_prefix
var exhale_counter
const exhale_counter_max = 12
var footstep_distance = 0
var footstep_count = 0
const footstep_distance_max = 10

var omni_used = false
var omni_count = 0
var omni_count_max = 16
var omni_animation_started = false
var omni_animation_count = 0
var omni_animation_count_max = 10
var omni_location = "Omni"

var dragonfly_mode
var dragonfly_animation_started

var type = "p"

var special = {}

const directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const len_soul = 4
const base_drag = 4
const BasicProjectile = preload("res://BasicProjectile.tscn")
const basic_projectiles = {"0_0_0_0": preload("res://basic_projectile_0_0_0_0.png"), "0_0_0_1": preload("res://basic_projectile_0_0_0_1.png"), "0_0_0_2": preload("res://basic_projectile_0_0_0_2.png"), "0_0_0_3": preload("res://basic_projectile_0_0_0_3.png"), "0_0_1_1": preload("res://basic_projectile_0_0_1_1.png"), "0_0_1_2": preload("res://basic_projectile_0_0_1_2.png"), "0_0_1_3": preload("res://basic_projectile_0_0_1_3.png"), "0_0_2_2": preload("res://basic_projectile_0_0_2_2.png"), "0_0_2_3": preload("res://basic_projectile_0_0_2_3.png"), "0_0_3_3": preload("res://basic_projectile_0_0_3_3.png"), "0_1_1_1": preload("res://basic_projectile_0_1_1_1.png"), "0_1_1_2": preload("res://basic_projectile_0_1_1_2.png"), "0_1_1_3": preload("res://basic_projectile_0_1_1_3.png"), "0_1_2_2": preload("res://basic_projectile_0_1_2_2.png"), "0_1_2_3": preload("res://basic_projectile_0_1_2_3.png"), "0_1_3_3": preload("res://basic_projectile_0_1_3_3.png"), "0_2_2_2": preload("res://basic_projectile_0_2_2_2.png"), "0_2_2_3": preload("res://basic_projectile_0_2_2_3.png"), "0_2_3_3": preload("res://basic_projectile_0_2_3_3.png"), "0_3_3_3": preload("res://basic_projectile_0_3_3_3.png"), "1_1_1_1": preload("res://basic_projectile_1_1_1_1.png"), "1_1_1_2": preload("res://basic_projectile_1_1_1_2.png"), "1_1_1_3": preload("res://basic_projectile_1_1_1_3.png"), "1_1_2_2": preload("res://basic_projectile_1_1_2_2.png"), "1_1_2_3": preload("res://basic_projectile_1_1_2_3.png"), "1_1_3_3": preload("res://basic_projectile_1_1_3_3.png"), "1_2_2_2": preload("res://basic_projectile_1_2_2_2.png"), "1_2_2_3": preload("res://basic_projectile_1_2_2_3.png"), "1_2_3_3": preload("res://basic_projectile_1_2_3_3.png"), "1_3_3_3": preload("res://basic_projectile_1_3_3_3.png"), "2_2_2_2": preload("res://basic_projectile_2_2_2_2.png"), "2_2_2_3": preload("res://basic_projectile_2_2_2_3.png"), "2_2_3_3": preload("res://basic_projectile_2_2_3_3.png"), "2_3_3_3": preload("res://basic_projectile_2_3_3_3.png"), "3_3_3_3": preload("res://basic_projectile_3_3_3_3.png")}
const FireShield = preload("res://FireShield.tscn")
const JiBreath = preload("res://JiBreath.tscn")
const Footsteps = preload("res://Footsteps.tscn")

const dragonfly_speed = 4000

signal soul_switch(soul)
signal player_hit(new_health, damage)
signal use_omni_gate()
signal ready_to_die()
signal player_move(old_position, old_speed, old_direction, displacement)
signal ji_ready()

func _init():
    invincible = true
    
    window_size = OS.get_real_window_size()
    #position = Vector2(window_size[0] / 2, window_size[1] / 2)
    
    soul = [0, 1, 2, 3]    
    speed = 0
    position = Vector2(450, -50)
    direction = Vector2.RIGHT
    
    max_health = 100
    health = max_health
    
    invincible = false
    
    fire_shield_counter = 0
    fire_shield_cooldown_counter = 0
    attack_cooldown_counter = 0
    ready_to_die = false
    die_counter = 0
    exhale_counter = 0
    
    last_delta = 100
    animation_prefix = "walk"
    dragonfly_mode = false
    dragonfly_animation_started = false
    
    update_stats(soul)

func update_stats(soul):
    spin_speed = get_spin_speed(soul)
    drag = get_drag(soul)
    initial_speed = get_initial_speed(soul)
    speed_limit = get_speed_limit(soul)
    initial_acceleration = get_initial_acceleration(soul)
    acceleration_growth = get_acceleration_growth(soul)
    stopping_speed = get_stopping_speed(soul)

# cloud ji doesn't leave footsteps. neither does dragonfly ji, but that's
# already handled
static func get_footsteps_on(soul):
    return !(soul[0] == 3 && soul[1] == 3 && soul[2] == 3 && soul[3] == 3)

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
    return 1 * (1 + get_soul_component(soul, 3))

static func get_speed_limit(soul):
    return 200 * (1 + get_soul_component(soul, 3))

static func get_initial_acceleration(soul):
    return 1000 * (1 + get_soul_component(soul, 3))

static func get_acceleration_growth(soul):
    return 5 * get_soul_component(soul, 3)

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
    #print(soul)
    if held_irla:
        held_irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        

func stand(_delta):
    animation_prefix = "stand"
    
func move(direction_index, delta):
    if speed == 0:
        speed = initial_speed
        
    speed += initial_acceleration * exp(acceleration_growth * delta) * delta
    
    if speed > speed_limit:
        speed = speed_limit
    
    if direction_index == 0:
        direction = Vector2.UP
    elif direction_index == 1:
        direction = Vector2.RIGHT
    elif direction_index == 2:
        direction = Vector2.DOWN
    elif direction_index == 3:
        direction = Vector2.LEFT
    elif direction_index == 4:
        direction = (Vector2.LEFT + Vector2.UP) / sqrt(2)
    elif direction_index == 5:
        direction = (Vector2.RIGHT + Vector2.UP) / sqrt(2)
    elif direction_index == 6:
        direction = (Vector2.RIGHT + Vector2.DOWN) / sqrt(2)        
    elif direction_index == 7:
        direction = (Vector2.LEFT + Vector2.DOWN) / sqrt(2)
    
    if get_soul_component(soul, 3) == 4:
        animation_prefix = "cloud"
        rotation = PI / 2 - direction.angle_to(directions[2])
        
    else:
        if animation_prefix == "cloud":
            rotation = 0
        animation_prefix = "walk"
    
    #print(speed)
    #print(direction)


func get_basic_projectile_texture(soul):
    var soul_sorted = [soul[0], soul[1], soul[2], soul[3]]
    soul_sorted.sort()
    return basic_projectiles["{0}_{1}_{2}_{3}".format([soul_sorted[0], soul_sorted[1], soul_sorted[2], soul_sorted[3]])]

func attack():
    #print("attack")
    #print("attack_cooldown_counter: %s" % attack_cooldown_counter)
    #print("held_irla null?: %s" % (held_irla == null))
    if !held_irla:
        return_irla()
    elif attack_cooldown_counter == 0:
        thrown_irla = held_irla
        held_irla = null
        #print("attack")
        attack_cooldown_counter = attack_cooldown_counter_max
        thrown_irla.held = false
        thrown_irla.direction = direction
        thrown_irla.get_node("CollisionShape2D").disabled = false
        var radius = thrown_irla.get_node("CollisionShape2D").shape.radius
        thrown_irla.position = position + direction * 2 * (radius + get_node("CollisionShape2D").shape.radius)
        thrown_irla.speed = speed
        thrown_irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        thrown_irla.soul = soul.duplicate()
        remove_child(thrown_irla)
        get_parent().add_child(thrown_irla)

func burn(damage):
    var animated_sprite = get_node("AnimatedSprite")
    animated_sprite.play("burn")
    health -= damage

func use_fire_shield():
    if fire_shield_cooldown_counter > 0:
        burn(1)
    else:
        fire_shield_cooldown_counter = 150
        fire_shield_counter = 150
        invincible = true
        fire_shield = FireShield.instance()
        add_child(fire_shield)

func use_omni_gate():
    # no cd for omni gate
    emit_signal("use_omni_gate")
    speed = 0
    omni_used = true
    omni_count = omni_count_max
    if thrown_irla:
        thrown_irla.speed = 0
        thrown_irla.position = position
        thrown_irla.visible = false
    if held_irla:
        held_irla.speed = 0
        held_irla.position = position
        held_irla.visible = false

func disable_fire_shield():
    invincible = false
    if fire_shield != null:
        #print("removing fire shield")
        remove_child(fire_shield)
    fire_shield = null
    fire_shield_counter = 0

func use_soul_special():
    var soul_sorted = [soul[0], soul[1], soul[2], soul[3]]
    soul_sorted.sort()
    var soul_string = "{0}_{1}_{2}_{3}".format(soul_sorted)
    #print("soul_string")
    #print(soul_string)
    if soul_string == "0_0_0_0":
        use_fire_shield()
    elif soul_string == "0_1_2_3":
        use_omni_gate()
    elif soul_string == "2_2_2_2":
        use_dragonfly()
    else:
        attack()

func start_dragonfly():
    dragonfly_mode = true
    
    # play start_dragonfly animation
    
func end_dragonfly():
    direction = Vector2.UP.rotated(rotation)
    speed = 0
    dragonfly_mode = false
    dragonfly_animation_started = false
    rotation = 0
    # play end_dragonfly animation

func use_dragonfly():
    if dragonfly_mode:
        end_dragonfly()
    else:
        start_dragonfly()

func _process(delta):        
    if first_run:
        # enter
        if speed == 0:
            speed = 1
        speed *= 1.5
        
        if get_parent().camera_centered:     
            if position.y >= 300:
                speed = 0
                position.y = 450
            else:
                position.y += speed * delta
        else:
            if position.y >= -150:
                speed = 0
                position.y = 0
            else:
                position.y += speed * delta
        
        return
    
    if omni_used:
        if omni_animation_started:
            invincible = true
        if omni_animation_count == 0:
            if speed == 0:
                speed = 1
            speed *= 1.5
            position.y -= speed * delta
        return
    
    if !ready_to_die:
        if knockback && knockback_velocity.length() > 0:
            var displacement = knockback_velocity * delta
            position += displacement
            var knockback_direction = knockback_velocity / knockback_velocity.length()
            knockback_velocity += drag * delta * knockback_direction
            if knockback_animation_started:
                rotation = Vector2.DOWN.angle_to(knockback_direction)
            emit_signal("player_move", position, knockback_velocity.length(), knockback_direction, displacement)
            return
        if dragonfly_mode:
            if Input.is_action_pressed("ui_accept"):
                # toggle dragonfly off
                #print("end dragonfly")
                use_dragonfly()
            else:
                # go really fast
                #print("enter dragonfly")
                var displacement = dragonfly_speed * direction * delta
                position += displacement
                if dragonfly_animation_started:
                    rotation = Vector2.UP.angle_to(direction)
                emit_signal("player_move", position, dragonfly_speed, direction, displacement)
            return
            
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
        
        # long chain of exclusive combinations of arrow key inputs, used to control direction of animation, speed of movement, and direction of movement
        if !(Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left")):
            # standing animation
            var sprite = get_node("AnimatedSprite")
            # sprite needs to not be rotated, so it is always face up
            sprite.rotation = 0
            rotation = 0
            #print("stand")
            stand(delta)
            
        elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
            pass
        
        elif Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
            move(1, delta)
        
        elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left"):
            move(2, delta)
        
        elif Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
            move(3, delta)
        
        elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_right"):
            move(0, delta)
        
        elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
            move(4, delta)
            
        elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
            move(5, delta)
            
        elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
            move(6, delta)
            
        elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_down"):
            move(7, delta)
        
        elif Input.is_action_pressed("ui_up"):
            move(0, delta)
            
        elif Input.is_action_pressed("ui_right"):
            move(1, delta)
            
        elif Input.is_action_pressed("ui_down"):
            move(2, delta)
            
        elif Input.is_action_pressed("ui_left"):
            move(3, delta)
    
    if speed <= 0:
        speed = 0
    elif speed > stopping_speed:
        speed -= drag * speed * delta   
    else:
        speed -= drag * stopping_speed * delta

    if speed < 0:
        speed = 0
    
    var displacement = min(speed_limit, speed) * delta * direction
    
    if displacement.length() > 0.00001:
        #print("player_move")
        emit_signal("player_move", position, speed, direction, displacement)
        #print(position)
        position += displacement

    if Input.is_action_just_pressed("ui_accept"):
        attack()
    
    # determine the closest cardinal direction, and animate based on that
    var angle = direction.angle_to(Vector2.RIGHT) * 180/PI # bounded [-180, 180)
    var sprite = get_node("AnimatedSprite")
    #print(angle)
    #print(animation_prefix)
    if speed == 0:
        if (angle >= 0 && angle <= 90) || (angle >= -90 && angle < 0):
            sprite.play("sit_right")
        else:
            sprite.play("sit_left")
    
    elif angle >= -22.5 && angle < 22.5:
        #print("walk_right")
        sprite.play(animation_prefix + "_right")
        
    elif angle >= 22.5 and angle < 67.5:
        #print("walk_back_right")
        sprite.play(animation_prefix + "_back_right")
        
    elif angle >= 67.5 and angle < 112.5:
        #print("walk_back")
        sprite.play(animation_prefix + "_back")
        
    elif angle >= 112.5 and angle < 157.5:
        #print("walk_back_left")
        sprite.play(animation_prefix + "_back_left")
        
    elif angle >= 157.5 || angle < -157.5:
        #print("walk_left")
        sprite.play(animation_prefix + "_left")
        
    elif angle >= -157.5 and angle < -112.5:
        #print("walk_front_left")
        sprite.play(animation_prefix + "_front_left")
        
    elif angle >= -112.5 and angle < -67.5:
        #print("walk_front")
        sprite.play(animation_prefix + "_front")
        
    elif angle >= -157.5 and angle < -22.5:
        #print("walk_front_right")
        sprite.play(animation_prefix + "_front_right")
    
    if thrown_irla and thrown_irla.hit:
        on_projectile_hit(thrown_irla)
    
    if footsteps_on && get_footsteps_on(soul):
        if footstep_distance > 0:
            footstep_distance -= displacement.length()
        else:
            var footsteps = Footsteps.instance()
            footsteps.id = footstep_count
            #footsteps.angle = Vector2.RIGHT.angle_to(direction)
            footsteps.position = position + Vector2.DOWN * $CollisionShape2D.shape.radius
            footsteps.z_index = -1
            footsteps.get_node("Sprite").rotation = direction.angle()
            get_parent().add_child(footsteps)
            footstep_distance = footstep_distance_max
            footstep_count += 1
    
    # hang onto the previous delta in case we need to use it to calculate stuff
    last_delta = delta
        
func take_damage(hit_base_damage, hit_soul, hit_direction):    
    knockback(hit_soul, hit_direction)
        
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
    
    emit_signal("player_hit", health, damage, max_health)
    
    #print("player hit by projecile soul: {0} {1} {2} {3}".format([hit_soul[0], hit_soul[1], hit_soul[2], hit_soul[3]]))
    #print("took damage: %s" % damage)
    #print("health remaining: %s" % health)
    
    if health <= 0:
        queue_die()
        
var knockback_count = 0
var knockback_count_max = 4
var knockback = false
var knockback_animation_started = false
var knockback_velocity = Vector2.ZERO

func knockback(hit_soul, hit_direction):
    var knockback_speed = 200 * (8 + get_soul_component(hit_soul, 0) + get_soul_component(hit_soul, 2) - 2 * get_soul_component(soul, 2))
    if knockback_speed > 0:
        knockback_velocity = knockback_speed * hit_direction
    else:
        # don't want this
        knockback_velocity = Vector2.ZERO
    knockback_count = knockback_count_max
    knockback = true

func queue_die():
    if ready_to_die:
        return
        
    die_counter = 4

    emit_signal("ready_to_die")

    get_node("CollisionShape2D").disabled = true

    drag = 12
    ready_to_die = true
    
func die():  
    if health > 0:
        health = 0
        emit_signal("player_hit", 0, 1, max_health)
    print("game over")
    
    var perms = []
    var seen = {}
    
    for i in 4:
        for j in 4:
            for k in 4:
                for l in 4:
                    var t = [i, j, k, l]
                    t.sort()
                    var s = "%s_%s_%s_%s" % [t[0], t[1], t[2], t[3]]
                    if !seen.has(s):
                        perms.append([i, j, k, l])
                        seen[s] = true
    
    for i in 35:     
        var soul = perms[i]
        var projectile = BasicProjectile.instance()
        projectile.direction = Vector2.RIGHT.rotated(i * 2 * PI / 35)
        projectile.position = position
        projectile.get_node("CollisionShape2D").disabled = true
        projectile.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        get_parent().add_child(projectile)

    queue_free()

func _on_Ji_area_entered(area):
    if "type" in area:
        if area.type != "p" && (area.type == "y" || area.type == "b"):
            if invincible && !area.ignore_invincible:
                return
            # not own projectile a marker => take damage
            take_damage(area.base_damage, area.soul, area.position.direction_to(position))
            area.hit = true

func return_irla():
    if !held_irla:
        #print("return_irla")
        if thrown_irla:
            get_parent().remove_child(thrown_irla)
            thrown_irla.queue_free()
            thrown_irla = null
        var new_irla = BasicProjectile.instance()
        new_irla.z_index = 1
        new_irla.speed = 0
        new_irla.base_speed = 0
        new_irla.get_node("CollisionShape2D").disabled = true
        var radius = new_irla.get_node("CollisionShape2D").shape.radius
        new_irla.position = position
        new_irla.direction = [direction[0], direction[1]]
        #new_irla.position = direction * 2 * (radius + get_node("CollisionShape2D").shape.radius)
        #new_irla.position = direction * 2 * get_node("CollisionShape2D").shape.radius
        new_irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)

        new_irla.visible = true
        new_irla.held = true
        held_irla = new_irla
        add_child(new_irla)

func _on_Beats_timeout():
    if first_run:
        var sprite = $AnimatedSprite
        
        if !first_run_animation_started:
            sprite.stop()
            sprite.animation = "enter"
            sprite.frame = 0
            sprite.play()
            first_run_animation_started = true
            
        if first_run_count > 0:
            first_run_count -= 1
        else:
            invincible = false
            first_run = false
            first_run_animation_started = false
            held_irla.visible = true
            emit_signal("ji_ready")
    
    if omni_used:
        var sprite = $AnimatedSprite
        
        if !omni_animation_started:
            $CollisionShape2D.disabled = true
            sprite.stop()
            sprite.animation = "exit"
            sprite.frame = 0
            sprite.play()
            omni_animation_count = omni_animation_count_max
            omni_animation_started = true
        
        if omni_animation_count > 0:
            omni_animation_count -= 1
            
        if omni_count > 0:
            omni_count -= 1
        else:
            var tree = get_tree()
            tree.change_scene("res://%s.tscn" % omni_location)
            omni_used = false
    
    if irla_hit:
        if irla_hit_animation_count > 0:
            irla_hit_animation_count -= 1
        else:
            if thrown_irla:
                thrown_irla.queue_free()
                get_parent().remove_child(thrown_irla)
                thrown_irla = null
            irla_hit = false
            return_irla()

    
    if knockback:
        var sprite = $AnimatedSprite
        if !knockback_animation_started:
            sprite.stop()
            sprite.animation = "knockback"
            sprite.frame = 0
            sprite.play()
            knockback_animation_started = true
            
        if knockback_count > 0:
            knockback_count -= 1
            
        else:
            knockback = false
            knockback_animation_started = false
    
    if dragonfly_mode:
        var sprite = $AnimatedSprite
        if !dragonfly_animation_started:
            sprite.play("dragonfly")
            dragonfly_animation_started = true
    
    if ready_to_die:
        #print(die_counter)
        if die_counter > 0:
            die_counter -= 1
        else:
            die()
    
    if fire_shield_counter > 0:
        fire_shield_counter -= 1
    else:
        disable_fire_shield()
        
    if fire_shield_cooldown_counter > 0:
        fire_shield_cooldown_counter -= 1
    
    if attack_cooldown_counter > 0:
        attack_cooldown_counter -= 1
    
    if breath_on:
        if exhale_counter > 0:
            exhale_counter -= 1
        else:
            exhale()
            exhale_counter = exhale_counter_max

func exhale():
    var breath = JiBreath.instance()
    breath.direction = direction.rotated(PI/16)
    breath.position = position + direction * $CollisionShape2D.shape.radius
    breath.get_node("AnimatedSprite").play("default")
    breath.z_index = 0
    get_parent().add_child(breath)

func _on_AnimatedSprite_animation_finished():
    pass
    #print("non-looping animation finished")
    #var animated_sprite = get_node("AnimatedSprite")
    #if animated_sprite.animat;ion != "default":
    #    animated_sprite.animation = "default"
    #    animated_sprite.play()

var parent

func _on_BasicProjectile_tree_entered():
    if (first_run):
        # prepare the first held irla, our companion and projectile
        #print("first irla")
        held_irla = $BasicProjectile
        held_irla.held = true
        held_irla.speed = 0
        held_irla.base_speed = 0
        held_irla.get_node("CollisionShape2D").disabled = true
        held_irla.position = direction * 2 * get_node("CollisionShape2D").shape.radius
        held_irla.get_node("Sprite").texture = get_basic_projectile_texture(soul)
        
        #hide irla until enter animation finishes
        held_irla.visible = false
        
        # check the location, and disable/enable footsteps, breath, etc
        footsteps_on = false
        breath_on = false
        
        if !parent:
            parent = get_parent()
            
        if ("snow" in parent) && parent.snow:
            # footsteps and breath are on in the "Omni", but not in "Arena"
            footsteps_on = true
            breath_on = true
        
        
var irla_hit = false
var irla_hit_animation_count = 0
var irla_hit_animation_count_max = 2

func on_projectile_hit(projectile):
    #print("projectile_hit") 
    if irla_hit:
        return
    irla_hit = true
    projectile.get_node("Sprite").visible = false
    projectile.get_node("AnimatedSprite").visible = true
    projectile.get_node("AnimatedSprite").stop()
    projectile.get_node("AnimatedSprite").animation = "hit"
    projectile.get_node("AnimatedSprite").frame = 0
    projectile.get_node("AnimatedSprite").play()
    irla_hit_animation_count = irla_hit_animation_count_max
