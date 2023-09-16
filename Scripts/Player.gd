extends CharacterBody2D


const SPEED = 10000.0
const MAX_SPEED = 250.0
const FRICTION = 0.5
const UPDOWNSPEED = 0.5


func _physics_process(delta):
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	direction = direction.normalized()
	direction.y *= UPDOWNSPEED
	
	if (direction.length() > 0):
		velocity += direction * SPEED * (1 - velocity.length() / MAX_SPEED) * delta
		velocity *= (1 - FRICTION * 0.1)
		$Sprite.play()
		$Sprite.speed_scale = 5 * (velocity.length() / MAX_SPEED)
	else:
		$Sprite.pause()
		velocity *= (1 - FRICTION)
	
	if (abs(direction.angle_to(Vector2.LEFT)) < deg_to_rad(45.0)):
		$Sprite.animation = "side"
		$Sprite.scale = Vector2(2,2)
	if (abs(direction.angle_to(Vector2.RIGHT)) < deg_to_rad(45.0)):
		$Sprite.animation = "side"
		$Sprite.scale = Vector2(-2,2)
	if (abs(direction.angle_to(Vector2.UP)) < deg_to_rad(45.0)):
		$Sprite.animation = "back"
		$Sprite.scale = Vector2(2,2)
	if (abs(direction.angle_to(Vector2.DOWN)) < deg_to_rad(45.0)):
		$Sprite.animation = "front"
		$Sprite.scale = Vector2(2,2)

	move_and_slide()
