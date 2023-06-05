extends Node

var progress = [0, 0, 0, 0]

onready var snow = true
onready var camera_centered = true

var moved_yet = false

const JiBreath = preload("res://JiBreath.tscn")
const IceWorm = preload("res://IceWorm.tscn")

signal diligent_dragonfly()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func save_game():
    var f = File.new()
    f.open("user://savegame.save", File.WRITE)
    var data = { "progress": progress }
    # Store the save dictionary as a new line in the save file.
    f.store_line(to_json(data))
    f.close()
    
func load_game():
    var f = File.new()
    if not f.file_exists("user://savegame.save"):
        return
    f.open("user://savegame.save", File.READ)
    var data = parse_json(f.get_line())
    progress = data.progress
    print("Ji load data: %s: ", data)
    f.close()

func _init():
    load_game()

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

var dragonfly_start_position
var dragonfly_end_position
var target_dragonfly_start_position = Vector2(450, 450)
var target_dragonfly_end_position
var dragonfly_position_tolerance
var dragonfly_start_position_error
var dragonfly_end_position_error
var best_dragonfly_start_position
var best_dragonfly_end_position
var smallest_dragonfly_start_position_error = INF
var smallest_dragonfly_end_position_error = INF

func _on_Ji_end_dragonfly(start_position, end_position):
    dragonfly_start_position = start_position
    dragonfly_end_position = end_position
    
    print("start_position: %s" % start_position)
    print ("end_position: %s" % end_position)
    
    if !target_dragonfly_end_position:
        target_dragonfly_end_position = $World/IcePortal.position
        
    if !dragonfly_position_tolerance:
        dragonfly_position_tolerance = $World/IcePortal/CollisionShape2D.shape.extents.x
    
    dragonfly_start_position_error = (dragonfly_start_position - target_dragonfly_start_position).length()
    dragonfly_end_position_error = (dragonfly_end_position - target_dragonfly_end_position).length()
    
    if smallest_dragonfly_start_position_error > dragonfly_start_position_error:
        best_dragonfly_start_position = dragonfly_start_position
        smallest_dragonfly_start_position_error = dragonfly_start_position_error
    
    if smallest_dragonfly_end_position_error > dragonfly_end_position_error:
        best_dragonfly_end_position = dragonfly_end_position
        smallest_dragonfly_end_position_error = dragonfly_end_position_error
    
    if ( dragonfly_start_position_error < dragonfly_position_tolerance ) && ( dragonfly_end_position_error < dragonfly_position_tolerance ):
        print("hooray")
        progress[0] = 1
        save_game()
        emit_signal("diligent_dragonfly")
    
    print("end position error: %s" % dragonfly_end_position_error)
    print("start position error: %s" % dragonfly_start_position_error)


func _on_Ground_area_exited(area):
    if ("type" in area) and (area.type == "p"):
        print("heyy")
        area.speed = 0
        var worm = IceWorm.instance()
        worm.position = area.position
        $World.add_child(worm)
