extends Area2D

var visible_count = 0
const visible_count_max = 32

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
