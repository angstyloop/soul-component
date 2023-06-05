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
    print("label load data: %s: ", data)
    f.close()

func _init():
    load_game()
    
    if progress[0] == 1:
        var name = "Diligent Dragonfly"
        print(name)
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[1] == 1:
        var name = "Frigid Fight"
        print(name)
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[2] == 1:
        var name = "Perilous Prize"
        print(name)
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[3] == 1:
        var name = "Sharp shooter"
        print(name)
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
            
    if progress[4] == 1:
        var name = "Tricky Tiles"
        print(name)
        bbcode_text = bbcode_text.replace(name, "[s]%s[/s]" % name)
        
func _on_Ji_yuki_die():
    load_game()
    bbcode_text = bbcode_text.replace("Frigid Fight", "[s]Frigid Fight[/s]") 
    
func _on_Board_complete():
    load_game()
    bbcode_text = bbcode_text.replace("Tricky Tiles", "[s]Tricky Tiles[/s]")

    
