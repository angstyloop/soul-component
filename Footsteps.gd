extends Area2D

onready var type = "f"

func _on_Footsteps_area_entered(area):
    if ("type" in area) and area.type == "f":
        get_parent().remove_child(self)
        queue_free()
        print("freed a footsteps tile")
