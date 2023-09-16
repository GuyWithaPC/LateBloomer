extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	var main_scene = load("res://Scenes/MainGame.tscn").instantiate()
	get_parent().add_child(main_scene)
	self.queue_free()
