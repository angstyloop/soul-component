extends Area2D

func _init():
    var size = OS.get_real_window_size()
    position = Vector2(size[0] / 2, size[1] / 2)

func _on_Trap_area_entered(area):
    print("gotcha!")
    area.speed = [0, 0, 0, 0]
    area.direction = Vector2.ZERO
    area.drag = 40

func _on_Trap_area_exited(area):
    print("aw...")
    area.drag = 10
