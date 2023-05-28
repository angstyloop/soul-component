extends Area2D

func _init():
    var size = OS.get_real_window_size()
    position = Vector2(size[0] / 2, size[1] / 2)

func _on_Trap_area_entered(area):
    if "speed" in area:
        area.speed = [0, 0, 0, 0]
    if "direction" in area:
        area.direction = Vector2.ZERO
    if "drag" in area:
        area.drag = 40
    if "type" in area:
        if area.type == "b":
            area.queue_free()

func _on_Trap_area_exited(area):
    if "drag" in area:
        area.drag = 10
