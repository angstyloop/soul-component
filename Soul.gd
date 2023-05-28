extends Area2D

const Soul0 = preload("res://Soul0.tscn");
const Soul1 = preload("res://Soul1.tscn");
const Soul2 = preload("res://Soul2.tscn");
const Soul3 = preload("res://Soul3.tscn");
const soul_scenes = [Soul0, Soul1, Soul2, Soul3];
const default_scene = Soul0

func _init():
    var offset = 0
    for i in 4:
        var node = default_scene.instance()
        var shape = node.get_node("SoulShape").shape
        var sprite_width = shape.extents.x
        node.position[0] += offset
        offset += sprite_width
        add_child(node)
    
static func remove_all_children(node):        
    for child in node.get_children():
        node.remove_child(child)
        child.queue_free()
            
func _on_Player_soul_switch(soul):
    if (len(get_children()) == 0):
        _init()
    else:
        var offset = 0
        remove_all_children(self)
        for i in soul:
            var node = soul_scenes[i].instance()
            var shape = node.get_node("SoulShape").shape
            var sprite_width = shape.extents.x
            node.position[0] += offset
            offset += sprite_width
            add_child(node)
