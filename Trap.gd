extends Area2D

var damage_key
var health

func _init():
    var size = OS.get_real_window_size()
    position = Vector2(size[0] / 2, size[1] / 2)
    
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
