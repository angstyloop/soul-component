extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var base_scale = 1.5

func _init():
    scale = Vector2(base_scale, base_scale)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func _on_Player_player_hit(new_health, damage, max_health):
    var t = base_scale * new_health / max_health
    scale = Vector2(t, t)
