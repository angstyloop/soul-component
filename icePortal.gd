extends Area2D

func _on_IcePortal_area_entered(area):
    if "type" in area:
        if area.type == "p":
            area.omni_location = "Arena"
            area.footsteps_on = false

func _on_IcePortal_area_exited(area):
    if "type" in area:
        if area.type == "p":
            area.footsteps_on = true
