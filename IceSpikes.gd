extends Area2D

func _on_IceSpikes_area_entered(area):
    if ice_spikes_on and ("type" in area) and area.type == "p":
        area.queue_die()

var ice_spikes_count_max = 5
var ice_spikes_count = ice_spikes_count_max
var ice_spikes_on = false

func _on_Timer_timeout():
    if ice_spikes_count > 0:
        ice_spikes_count -= 1
    else:
        ice_spikes_on = true
