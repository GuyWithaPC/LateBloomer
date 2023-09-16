extends CharacterBody2D


const SPEED = 10000.0
const MAX_SPEED = 250.0
const FRICTION = 0.5
const UPDOWNSPEED = 0.5

enum Item {
	None = 420,
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
var money: int = 10

@onready
var root = get_tree().root.get_node("Root")

func shop(button: String, cost: int):
	if item_type != Item.None and item_type != Item[button]:
		return
	money -= cost
	item_type = Item[button]
	item_count += 1

func _ready():
	for button in $GUI/ShopScreen.get_children():
		if button.name == "Label":
			continue
		button.connect("pressed", self.shop.bind(button.name, int(button.text.trim_prefix("$"))))

func _process(delta):
	if item_count == 0:
		item_type = Item.None
	$GUI/ItemCount.text = str(item_count)
	$GUI/Money.text = "$%s" % str(money)
	var inShop = false
	for area in $Planter.get_overlapping_areas():
		if area.name == "ShopZone":
			inShop = true
	$GUI/ShopScreen.visible = inShop
	
	for button in $GUI/ShopScreen.get_children():
		if button.name == "Label":
			continue
		var cost: int = int(button.text.trim_prefix("$"))
		if money >= cost:
			button.disabled = false
		else:
			button.disabled = true
	
	# update the selected square
	var closest = null
	var offset_position = self.position + Vector2(0,8)
	for spot in get_tree().get_nodes_in_group("CropPositions"):
		spot.get_node("Selected").visible = false
		if closest == null:
			closest = spot
		elif offset_position.distance_to(spot.position) < offset_position.distance_to(closest.position):
			closest = spot
	if offset_position.distance_to(closest.position) > 25:
		closest = null
	if closest != null:
		closest.get_node("Selected").visible = true
	
	# plant in the selected square if the player presses space
	if Input.is_action_pressed("plant") and closest != null:
		if item_count > 0:
			item_count -= 1 if root.plant(closest.name, item_type) else 0
	
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
	
	money += root.harvest(area.name)
