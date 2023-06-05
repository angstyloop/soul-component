extends AudioStreamPlayer2D

const ji_death = preload("res://ji_death.wav")

func _on_Timer_timeout():
    if not playing:
        volume_db = 0
        play()

func _on_Ji_ready_to_die():
    stop()
    volume_db = -10
    stream = ji_death
    autoplay = false
    play()


func _on_Ji_ji_ready():
    play()
