extends Node2D

var tree_ready = false

onready var can_rotate = false
onready var top_boundary_position = 0
onready var right_boundary_position = 450 * 2
onready var bottom_boundary_position = 450 * 2
onready var left_boundary_position = 0

func reverse_rotation(ji, zero_one_or_two):
    if zero_one_or_two == 1:
        if ji.rotation < 180:
            ji.rotation += 180
        else:
            ji.rotation -= 180

func _process(delta):
    if ! tree_ready:
        return

    var zero_one_or_two = 0
    var ji = $Ji
    var radius = ji.get_node("CollisionShape2D").shape.radius
    
    if ji.position.x <= left_boundary_position + radius:
        zero_one_or_two += 1
        ji.position.x = left_boundary_position + radius
        reverse_velocity(ji, 0)
    
    elif ji.position.x >= right_boundary_position - radius:
        zero_one_or_two += 1
        ji.position.x = right_boundary_position - radius
        reverse_velocity(ji, 0)
            
    if ji.position.y <= top_boundary_position + radius:
        zero_one_or_two += 1
        ji.position.y = top_boundary_position + radius    
        reverse_velocity(ji, 1)
        
    elif ji.position.y >= bottom_boundary_position - radius:
        zero_one_or_two += 1
        ji.position.y = bottom_boundary_position - radius
        reverse_velocity(ji, 1)

    if can_rotate:
        reverse_rotation(ji, zero_one_or_two)

func _on_Ji_child_entered_tree():
    tree_ready = true

func reverse_velocity(ji, zero_or_one):
    var t = ji.speed[0]
    ji.speed[0] = ji.speed[2]
    ji.speed[2] = t
    ji.direction[zero_or_one] = -ji.direction[zero_or_one]
