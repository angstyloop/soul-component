extends Area2D

func _init():
    var size = OS.get_real_window_size()
    position = Vector2(size[0] / 2, size[1] / 2)
