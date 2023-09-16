extends CharacterBody2D


const SPEED = 10000.0
const MAX_SPEED = 250.0
const FRICTION = 0.5
const UPDOWNSPEED = 0.5

enum Item {
	None,
	Carrot = 0,
	Tomato = 1,
	Wheat = 2,
	Corn = 3,
	Brawndo = 4,
	Plutonium = 5,
	Ammonia = 6,
	Gasoline = 7,
	Steroids = 8,
	IPad = 9,
	CarBattery = 10,
	Music = 11
}
var item_count: int = 0
var item_type: Item = Item.None
var money: int = 100

@onready
var root = get_tree().root.get_node("Root")

func _ready():
	item_type = Item.Tomato
	item_count = 4

func _process(delta):
	if item_count == 0:
		item_type = Item.None
	$GUI/ItemCount.text = str(item_count)
	$GUI/Money.text = "$%s" % str(money)
	
	if item_type == Item.None:
		$GUI/ItemCount.visible = false
	else:
		$GUI/ItemCount.visible = true
		$GUI/ItemCount/ItemType.frame = item_type

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
	if Input.is_action_just_pressed("ui_cancel"):
		item_count = 2
		item_type = Item.Steroids
	
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


func _on_planter_area_entered(area):
	if !area.is_in_group("CropPositions"):
		return
	
	if item_count > 0:
		item_count -= 1 if root.plant(area.name, item_type) else 0
	
	money += root.harvest(area.name)
