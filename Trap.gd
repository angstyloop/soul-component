extends Area2D

var damage_key
var health

const projectile_texture = preload("res://basic_projectile.png")
const BasicProjectile = preload("res://BasicProjectile.tscn")

func _init():
    #var size = OS.get_real_window_size()
    #position = Vector2(size[0] / 2, size[1] / 2)
    
    damage_key = [-1, -1, 1, 1]
    health = 10

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

func attack_player():
    var player = get_parent().get_node("Player")
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
    proj.base_speed = 2
    proj.soul = [0, 0, 0, 0]
    proj.get_node("Sprite").texture = projectile_texture
    get_parent().add_child(proj)
    

func tick():
    attack_player()

func _on_Timer_timeout():
    tick()
    pass # Replace with function body.
