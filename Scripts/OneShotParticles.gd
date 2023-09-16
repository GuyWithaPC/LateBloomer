extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.emitting = true

func setup(color: Color):
	self.modulate = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !self.emitting:
		self.queue_free()
