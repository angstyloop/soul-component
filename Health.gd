extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var base_scale = 1.5

func _init():
    scale = Vector2(base_scale, base_scale)

func _on_Player_player_hit(new_health, damage, max_health):
    var t = base_scale * new_health / max_health
    scale = Vector2(t, t)
