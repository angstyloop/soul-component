extends Node

onready var snow = true
onready var camera_centered = true

var moved_yet = false

const JiBreath = preload("res://JiBreath.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func _on_Ji_player_move(old_position, old_speed, old_direction, displacement):
    #print("player_move in World")
    $World.position -= displacement

    
    if not moved_yet:
        moved_yet = true


func _on_Ji_tree_entered():
    # board and its children will also magically be ready
    var extents = $World/Board/CollisionShape2D.shape.extents
    #$World/Ji.position = Vector2(extents.x, extents.y)

func _on_Beats_timeout():
    if not moved_yet:
        return

func _on_Ji_use_omni_gate():
    moved_yet = false
