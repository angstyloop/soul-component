extends RichTextLabel

var progress = [0, 0, 0, 0, 0]

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
    f.close()

func _init():
    load_game()
    
    if progress[0] == 1:
        var name = "Diligent Dragonfly"
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[1] == 1:
        var name = "Frigid Fight"
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[2] == 1:
        var name = "Perilous Prize"
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[3] == 1:
        var name = "Sharp Shooter"
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[4] == 1:
        var name = "Tricky Tiles"
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
        
func _on_Ji_yuki_die():
    load_game()
    bbcode_text = bbcode_text.replace("Frigid Fight", "[s]Frigid Fight[/s]") 
    
func _on_Board_complete():
    load_game()
    bbcode_text = bbcode_text.replace("Tricky Tiles", "[s]Tricky Tiles[/s]")

func _on_Omni_diligent_dragonfly():
    load_game()
    bbcode_text = bbcode_text.replace("Diligent Dragonfly", "[s]Diligent Dragonfly[/s]")


func _on_Trap_sharp_shooter():
    load_game()
    bbcode_text = bbcode_text.replace("Sharp Shooter", "[s]Sharp Shooter[/s]")


func _on_Trap_perilous_prize():
    load_game()
    bbcode_text = bbcode_text.replace("Perilous Prize", "[s]Perilous Prize[/s]")
    
