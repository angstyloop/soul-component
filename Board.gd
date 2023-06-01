extends Area2D

# The length (in square units) of the (square) board.
var n: int = 9

# The side length of a square unit in pixels.
var unit_length: int = 100

# The board length in pixels.
var board_length: int = n * unit_length

# A reference to the last card clicked, or null if no card has been clicked yet.
var card = null

# Load the Card scene, so we can instance it to make Nodes.
var card_scene = load("res://Card.tscn")

# This array will hold our Card Nodes (the instances of the Card scene we
# just loaded)
var cards_array: Array = []

# For clarity, define variables for the card width and height explicitly, even
# though they are equal since the cards are square. Each card has the
# dimensions of a square unit. 
var cards_array_width: int = n
var cards_array_height: int = n

# This holds our mouse position, which we don't use yet, but we keep track of
# in our _input callback function.
var mpos = Vector2(0, 0)

# Create the board
func create_board():
    # Set the "extents" of the Board's CollisionShape2D.
    #$CollisionShape2D.shape.extents.x = unit_length / 2 * cards_array_width
    #$CollisionShape2D.shape.extents.y = unit_length / 2 * cards_array_height

    # Set the "scale" of the Board's Sprite
    #$Sprite.scale.x = cards_array_width
    #$Sprite.scale.y = cards_array_height

    # Position the board 
    global_position = Vector2(450, 450)

    # Position the Board's Sprite in the same place as the Board.
    $Sprite.global_position = global_position

    # Center the Board's sprite
    $Sprite.centered = true

    # Make the Board visible.
    visible = true

func destroy_board():
    visible = false

# Create the cards.
func create_cards():
    # Allocate memory for the cards in an array. The array is 1d, but we'll be
    # storing 2D data.
    cards_array.resize(cards_array_width * cards_array_height)

    # Fill cards_array with cards.
    for y in range(cards_array_height):
        for x in range(cards_array_width):
            # Instance our Card Scene to make a new Card
            var new_card = card_scene.instance()

            # Make each card invisible
            new_card.visible = false
            
            # Position the new card in correct space on the board.
            new_card.global_position.x = x * unit_length - board_length / 2 + unit_length / 2
            new_card.global_position.y = y * unit_length - board_length / 2 + unit_length / 2
            
            # Set the "extents" on each Card's CardShape to 
            new_card.get_node("CardShape").shape.extents.x = unit_length / 2
            new_card.get_node("CardShape").shape.extents.y = unit_length / 2
            
            add_child(new_card)
            
            cards_array[y * cards_array_width + x] = new_card 

func destroy_cards():
    # Removing each Card Node from its parent Node (Board)
    for card in cards_array:
        remove_child(card)
        
    # Resize the array of Cards to zero
    cards_array.resize(0)

func _ready():
    # Set the @n SpinBox's default value
    if $SpinBox != null:
        $SpinBox.value = n

    # Create the board
    create_board()

    # Create the cards
    create_cards()

func _process(_delta):
    pass

func _input(ev):
    if ev is InputEventMouseButton and ev.button_index == BUTTON_LEFT:
        if ev.pressed:
            var evpos = ev.global_position
            
            var gpos = global_position

            if (gpos.x - board_length / 2 < evpos.x) && (evpos.x < gpos.x + board_length / 2) && (gpos.y - board_length / 2 < evpos.y) && (evpos.y < gpos.y + board_length / 2):
                if card != null:
                    card.visible = false

                var y_index = floor((evpos.y - gpos.y + board_length / 2) / unit_length);
                var x_index = floor((evpos.x - gpos.x + board_length / 2) / unit_length);

                card = cards_array[y_index * cards_array_width + x_index]
                
                
                if card != null:
                    card.visible = true

    if ev is InputEventMouseMotion or ev is InputEventMouseButton:
        mpos = ev.global_position

# Previous value
var prev_value = null
var curr_value = null

func _on_SpinBox_value_changed(value):
    if (0 <= value && value <= 10):
        # Print stuff for debugging
        prev_value = curr_value
        curr_value = value

        # Set @n to the new value. Update everything that depends on @n.
        n = value
        board_length = n * unit_length
        cards_array_width = n
        cards_array_height = n

        # Destroy the cards
        destroy_cards()

        # Destroy the board
        destroy_board()

        # Create the board
        create_board()

        # Recreate the cards with the new size.
        create_cards()