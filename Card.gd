extends Area2D

var visible_count = 0

# with cloud ji: 128 easy, 64 medium, 48 hard but beaten, 32 very hard (maybe impossible)
# when using the trap instead, it's obviously easy and fast! but note that
# for speedruns you should REALLY start counting from omni
const visible_count_max = 48

func _on_Card_area_entered(area):
    if visible:
        return

    if ("type" in area) and area.type != "B":
        visible_count = visible_count_max
        visible = true
        
func _on_Timer_timeout():
    if visible:
        if visible_count > 0:
            visible_count -= 1
        else:
            if !get_parent().complete:
                visible = false
