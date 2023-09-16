extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$GUI/Label2.text = str(get_node("/root/GlobalVariables").score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_button_down():
	var start_screen = load("res://Scenes/StartScreen.tscn").instantiate()
	get_parent().add_child(start_screen)
	self.queue_free()
