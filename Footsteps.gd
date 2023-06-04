extends Area2D

onready var type = "f"
onready var id = -1

func _on_Footsteps_area_entered(area):
    if ("type" in area) and area.type == "f":
        var older = self
        if area.id < id:
            older = area
        older.id = -1
        older.queue_free()
