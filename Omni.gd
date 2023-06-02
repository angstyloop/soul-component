extends Node

const max_positions = 100
var positions_forget_count_max = 4
var positions_forget_count = positions_forget_count_max
var positions_remember_count_max = 4
var positions_remember_count = positions_remember_count_max
var old_points = []
var moved_yet = false

const BasicProjectile = preload("res://BasicProjectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func _on_Ji_player_move(old_position, old_speed, old_direction, displacement):
    #print("player_move in World")
    $World.position -= displacement
    var point = [old_position, old_speed, old_direction, displacement, null]

    #for old_point in old_points:
    #    old_point[4].position -= displacement
    
    if old_points.size() > max_positions:
        var old_point = old_points.pop_front()
        remove_child(old_point[4])
    
    if positions_remember_count == 0:
        #print("positions_remember_count: %s" % positions_remember_count)
        var marker = BasicProjectile.instance()
        marker.position = old_position
        point[4] = marker
        marker.get_node("CollisionShape2D").disabled = true
        $World.add_child(marker)
        old_points.push_back(point)
        positions_remember_count = positions_remember_count_max
    
    if not moved_yet:
        moved_yet = true

func _on_Ji_tree_entered():
    # board and its children will also magically be ready
    var extents = $World/Board/CollisionShape2D.shape.extents
    $World/Ji.position = Vector2(extents.x, extents.y)

func _on_Beats_timeout():
    if not moved_yet:
        return

    #print("beat")
    
    if positions_remember_count > 0:
        positions_remember_count -= 1
        
    if positions_forget_count > 0:
        positions_forget_count -= 1
    elif old_points.size() > 1:
        var point = old_points.pop_front()
        if point && point[4]:
            remove_child(point[4])
            point[4].queue_free()
            positions_forget_count = positions_forget_count_max
    



func _on_Ji_use_omni_gate():
    moved_yet = false
